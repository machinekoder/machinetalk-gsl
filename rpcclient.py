import zmq
import threading
from machinetalk.protobuf.types_pb2 import *

def RpcClient(object):
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
        self.socket_uri = ''
        self.socket_service = ''
        self.socket = self.context.socket(zmq.DEALER)
        self.socket.setsockopt(zmq.LINGER, 0)
        # more efficient to reuse a protobuf message
        self.socket_rx = Container()
        self.socket_tx = Container()

        # Heartbeat
        self.heartbeat_period = 2500
        self.heartbeat_error_count = 0
        self.heartbeat_error_threshold = 2
        self.heartbeat_timer = None

        self.message_received_cb = None
        self.state_changed_cb = None
        self.started = False

        # fsm
        self.state = DOWN

    def socket_worker(self):
        poll = zmq.Poller()
        poll.register(self.socket, zmq.POLLIN)

        while not self.shutdown.is_set():
            s = dict(poll.poll(200))
            if self.socket in s:
                self.process_socket()

    def process_socket(self):
        msg = self.socket.recv()
        self.socket_rx.ParseFromString(msg)
        if self.debuglevel > 0:
            print('[%s] received message' % self.debugname)
            if self.debuglevel > 1:
                print(self.socket_rx)

        self.fsm.connected()

        if self.socket_rx.type == MT_PING_ACKNOWLEDGE: # ping acknowledge is uninteresting
            return

        self.message_received_cb(self.socket_rx)

    def start(self):
        if self.started:
            return
        self.started = True
        self.fsm.init()
        self.fsm.connect()  # todo
        self.shutdown.clear()
        self.thread = threading.Thread(target=self.socket_worker)
        self.thread.start()

    def stop(self):
        if not self.started:
            return
        self.started = False
        self.shutdown.set()
        self.thread.join()
        self.thread = None
        self.fsm.disconnect()

    def connect_sockets(self):
        self.socket_service = self.socketuri    # make sure to save the uri we connected to
        self.socket.connect(self.socket_service)
        return True

    def disconnect_sockets(self):
        self.socket.disconnect(self.socket_service)

    def heartbeat_tick(self):
        self.send_ping
        self.heartbeat_error_count += 1

        if self.heartbeat_error_count > self.heartbeat_error_threshold:
            self.fsm.timeout()

        self.timer_lock.acquire()
        self.heartbeat_timer = threading.Timer(self.heartbeat_period / 1000,
                                             self.heartbeat_tick)
        self.heartbeat_timer.start()  # rearm timer
        self.timer_lock.release()

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

