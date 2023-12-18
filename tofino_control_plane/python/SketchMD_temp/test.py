argparser = argparse.ArgumentParser(description="Zeus Control Plane")
argparser.add_argument('--grpc_server', type=str, default='localhost', help='GRPC server name/address')
argparser.add_argument('--grpc_port', type=int, default=50052, help='GRPC server port')
argparser.add_argument('--program', type=str, default='zeus_main', help='P4 program name')

# add BF Python to search path
try:
    # Import BFRT GRPC stuff
    import bfrt_grpc.bfruntime_pb2 as bfruntime_pb2
    import bfrt_grpc.client as gc
    import grpc
except:
    sys.path.append(os.environ['SDE_INSTALL'] + "/lib/python2.7/site-packages/tofino")
    import bfrt_grpc.bfruntime_pb2 as bfruntime_pb2
    import bfrt_grpc.client as gc
    import grpc

from Ports import Ports

# connect to GRPC server
logger.info("Connecting to GRPC server {}:{} and binding to program {}...".format(args.grpc_server, args.grpc_port, args.program))
c = gc.ClientInterface("{}:{}".format(args.grpc_server, args.grpc_port), 0, 0, is_master=False)
c.bind_pipeline_config(args.program)

# get all tables for program
bfrt_info = c.bfrt_info_get(args.program)

ports = Ports(gc, bfrt_info)
port_list = [1, 2, 3, 4, 10, 11]
for port in port_list:
    ports.add_port(port, 0, 100, 'rs')

