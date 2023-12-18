import traceback
import time
def hun_timer(name, limit):
    for i in range(0, limit):
        time.sleep(1)
        try:
            print("[%s] timer - [%d/%d]" % (name, i+1, limit))
        except Exception as e:
            print("[%s] timer except pass" % name)
            traceback.print_exc()
