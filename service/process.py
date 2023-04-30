import multiprocessing as mtp

class ProcessManager:
    def __init__(self):
        self.processes = {}

    def add_process(self, alias, worker, inputs:tuple = None, outputs:tuple = None):
        if inputs is None:
            inputs = (mtp.Queue())
        if outputs is None:
            outputs = (mtp.Queue())
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
                self.processes[destination].inputs += (linked,)
                self.processes[source].outputs += (linked,)
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
    def __init__(self, worker, inputs:tuple, outputs:tuple):
        self.worker = worker
        self.inputs = inputs
        self.outputs = outputs

    def build(self):
        self.process = mtp.Process(target=self.worker, args=(self.inputs, self.outputs))

    def start(self):
        self.process.daemon = True
        self.process.start()

    def stop(self, stop_message):
        self.inputs.put(stop_message)
        self.process.join()
        self.process = None
        self.input = None
        self.output = None

