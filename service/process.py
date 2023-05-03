from collections import namedtuple
import multiprocessing as mtp

def tuple_append(v:tuple, a):
    return 

process_argument = namedtuple('prcargs', ['input', 'output', 'args'])

class ProcessManager:
    def __init__(self):
        self.processes = {}

    def add_process(self, alias, worker, inputs:tuple=(), outputs:tuple=(), args:tuple=()):
        process_args = [inputs, outputs, args]
        new_process = Process(worker=worker, args=process_args)
        self.processes[alias] = new_process

    def add_io(self, alias, io:str):
        try:    
            if alias not in self.processes:
                raise AttributeError
            if 'i' in io:
                self.processes[alias].args[0] = self.processes[alias].args[0] + (mtp.Queue(),)
            if 'o' in io:
                self.processes[alias].args[1] = self.processes[alias].args[1] + (mtp.Queue(),)
        except AttributeError:
            raise KeyError(f'Attribute {alias} is not found')

    def link(self, source, destination, link=None, keep_exist=True):
        linked = link if link is not None else mtp.Queue()
        try:
            if source not in self.processes and destination not in self.processes:
                raise KeyError
            if keep_exist:
                self.processes[destination].args[0] = self.processes[destination].args[0] + (linked,)
                self.processes[source].args[1] = self.processes[source].args[1] + (linked,)
                print(f'Create link {source}->{destination} with keep exist queue')
            else:
                self.processes[destination].args[0] = self.processes[source].args[1] = (linked,)
                print(f'Create link {source}->{destination} with remove exist queue')
        except KeyError:
            raise KeyError(f'One of key is not founded in process lists while create link {source}->{destination}')
        except Exception as e:
            print(f'Some Error has occured whild create link {source}->{destination}: {e}')
    
    def get_process_by_alias(self, alias):
        if alias in self.processes:
            return self.processes[alias]
        else:
            return None
    
    def get_connection_by_alias(self, alias):
        if alias in self.processes:
            return self.processes[alias].args[0], self.processes[alias].args[0]
        else:
            None

    def put(self, alias, data):
        if alias in self.processes:
            self.processes[alias].args[0][0].put(data)

    def start_all_process(self):
        for process in self.processes.values():
            print(f'Starting process: {process.worker}\n with: {process.args}')
            process.build(use_daemon=True)
            process.start()

    def stop_all_process(self, stop_message):
        for process in self.processes:
            process.stop(stop_message)
            
class Process:
    def __init__(self, worker, args:list=[]):
        self.worker = worker
        self.args = args
        self.process = None
    
    def build(self, use_daemon:bool=False):
        _args = ()
        for arg in self.args:
            _args = _args + (arg,)
        self.process = mtp.Process(target=self.worker, args=_args)
        self.process.daemon = use_daemon
    
    def start(self):
        self.process.start()
    
    def stop(self, stop_message):
        self.args[0].put(stop_message)
        self.process.join()
        self.process = None
        self.args = None