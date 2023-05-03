import multiprocessing as mtp

class ProcessManager:
    def __init__(self):
        self.processes = {}

    def add_process(self, alias, worker, inputs:tuple = None, outputs:tuple = None):
        if inputs is None:
            inputs = ()
        if outputs is None:
            outputs = ()
        new_process = Process(worker=worker,
                              inputs=inputs,
                              outputs=outputs)
        self.processes[alias] = new_process

    def link(self, source, destination, link=None, keep_exist=True):
        linked = link if link is not None else mtp.Queue()
        try:
            if source not in self.processes and destination not in self.processes:
                raise KeyError
            if keep_exist:
                old_dest_inputs = self.processes[destination].inputs
                old_source_outputs = self.processes[source].outputs
                self.processes[destination].inputs = tuple(list(old_dest_inputs).insert(linked))
                self.processes[source].outputs = tuple(list(old_source_outputs).insert(linked))
            else:
                self.processes[destination].inputs = self.processes[source].outputs = (linked,)
        except KeyError:
            raise KeyError(f'One of key is not founded in process lists while create link {source} -> {destination}')
        except Exception as e:
            print(e)
    
    def get_process_by_alias(self, alias):
        if alias in self.processes:
            return self.processes[alias]
        else:
            return None
    
    def get_connection_by_alias(self, alias):
        if alias in self.processes:
            return self.processes[alias].inputs, self.processes[alias].outputs
        else:
            None

    def put(self, alias, data):
        if alias in self.processes:
            self.processes[alias].inputs.put(data)

    def start_all_process(self):
        for process in self.processes.values():
            process.build()
            process.start()

    def stop_all_process(self, stop_message):
        for process in self.processes:
            process.stop(stop_message)
            
class Process:
    def __init__(self, worker:function, args:tuple=None):
        self.worker = worker
        self.args = args
        self.process = None
    
    def build(self, use_daemon:bool=False):
        self.process = mtp.Process(target=self.worker, args=self.args)
        self.process.daemon = use_daemon
    
    def start(self):
        self.process.start()
    
    def stop(self, stop_message):
        self.inputs.put(stop_message)
        self.process.join()
        self.process = None
        self.args = None