import zmq
import threading
from fysom import Fysom

from machinetalk.protobuf.types_pb2 import *
from machinetalk.protobuf.message_pb2 import Container


class RpcClient(object):
    def __init__(self, debuglevel=0, debugname='rpcclient'):
        self.debuglevel = debuglevel
        self.debugname = debugname
        self.thread = None
        self.shutdown = threading.Event()
        self.tx_lock = threading.Lock()
        self.timer_lock = threading.Lock()

        # ZeroMQ
        context = zmq.Context()
        context.linger = 0
        self.context = context

        # Socket
        self.uri = ''
        self.service = ''
        self.socket = self.context.socket(zmq.DEALER)
        self.socket.setsockopt(zmq.LINGER, 0)
        # more efficient to reuse a protobuf message
        self.rx = Container()
        self.tx = Container()

        # Heartbeat
        self.heartbeat_period = 2500
        self.heartbeat_error_count = 0
        self.heartbeat_error_threshold = 2
        self.heartbeat_timer = None

        self.message_received_cb = None
        self.state_changed_cb = None
        self.started = False

        # fsm
        self.fsm = Fysom({'initial': 'down',
                          'events': [
                            {'name': 'connect', 'src': 'down', 'dst': 'trying'},
                            {'name': 'connected', 'src': 'trying', 'dst': 'up'},
                            {'name': 'disconnect', 'src': 'trying', 'dst': 'down'},
                            {'name': 'timeout', 'src': 'up', 'dst': 'trying'},
                            {'name': 'disconnect', 'src': 'up', 'dst': 'down'},
                          ]})

        self.fsm.onconnect = self.on_fsm_connect
        self.fsm.onconnected = self.on_fsm_connected
        self.fsm.ondisconnect = self.on_fsm_disconnect
        self.fsm.ontimeout = self.on_fsm_timeout

    def on_fsm_connect(self, e):
        print('[%s]: connect' % self.debugname)
        self.connect_sockets()
        self.refresh_heartbeat()
        self.send_ping()
        return True

    def on_fsm_connected(self, e):
        print('[%s]: connected' % self.debugname)
        self.refresh_heartbeat()
        return True

    def on_fsm_disconnect(self, e):
        print('[%s]: disconnect' % self.debugname)
        self.stop_heartbeat()
        self.disconnect_sockets()
        return True

    def on_fsm_timeout(self, e):
        print('[%s]: timeout' % self.debugname)
        return True

    def socket_worker(self):
        poll = zmq.Poller()
        poll.register(self.socket, zmq.POLLIN)

        while not self.shutdown.is_set():
            s = dict(poll.poll(200))
            if self.socket in s:
                self.process_socket()

    def process_socket(self):
        msg = self.socket.recv()
        self.rx.ParseFromString(msg)
        if self.debuglevel > 0:
            print('[%s] received message' % self.debugname)
            if self.debuglevel > 1:
                print(self.rx)

        self.reset_heartbeat()

        if self.fsm.isstate('trying'):
            self.fsm.connected()


        if self.rx.type == MT_PING_ACKNOWLEDGE: # ping acknowledge is uninteresting
            return

        self.message_received_cb(self.rx)

    def start(self):
        if self.started:
            return
        self.started = True
        self.fsm.connect()  # todo
        self.shutdown.clear()
        self.thread = threading.Thread(target=self.socket_worker)
        self.thread.start()

    def stop(self):
        if not self.started:
            return
        self.started = False
        self.fsm.disconnect()
        self.shutdown.set()
        self.thread.join()
        self.thread = None

    def connect_sockets(self):
        self.service = self.uri  # make sure to save the uri we connected to
        self.socket.connect(self.service)
        return True

    def disconnect_sockets(self):
        self.socket.disconnect(self.service)

    def heartbeat_tick(self):
        if self.debuglevel > 0:
            print('[%s] heartbeat tick' % self.debugname)
        self.send_ping()
        self.heartbeat_error_count += 1

        if self.heartbeat_error_count > self.heartbeat_error_threshold:
            if self.fsm.isstate('up'):
                self.fsm.timeout()

        #self.timer_lock.acquire()
        #self.heartbeat_timer = threading.Timer(self.heartbeat_period / 1000,
        #                                     self.heartbeat_tick)
        #self.heartbeat_timer.start()  # rearm timer
        #self.timer_lock.release()

    def reset_heartbeat(self):
        self.heartbeat_error_count = 0

    def refresh_heartbeat(self):
        self.timer_lock.acquire()
        if self.heartbeat_timer:
            self.heartbeat_timer.cancel()
            self.heartbeat_timer = None

        if self.heartbeat_period > 0:
            self.heartbeat_timer = threading.Timer(self.heartbeat_period / 1000,
                                                 self.heartbeat_tick)
            self.heartbeat_timer.start()
        self.timer_lock.release()
        if self.debuglevel > 0:
            print('[%s] heartbeat updated' % self.debugname)

    def stop_heartbeat(self):
        self.timer_lock.acquire()
        if self.heartbeat_timer:
            self.heartbeat_timer.cancel()
            self.heartbeat_timer = None
        self.timer_lock.release()

    def send_message(self, msg_type, tx):
        with self.tx_lock:
            tx.type = msg_type
            if self.debuglevel > 0:
                print('[%s] sending message: %s' % (self.debugname, msg_type))
                if self.debuglevel > 1:
                    print(str(tx))

            self.socket.send(tx.SerializeToString(), zmq.NOBLOCK)
            tx.Clear()

        self.refresh_heartbeat()

    def send_ping(self):
        self.send_message(MT_PING, self.tx)

