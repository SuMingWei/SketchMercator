from global_var import H

def isHeaderInFlowkeys(F, h):
    for fi in F:
        if h in fi:
            return True
    return False

def isHeaderMergeable(F, h1, h2):
    for fi in F:
        if h1 in fi and not (h2 in fi):
            return False
        if not (h1 in fi) and h2 in fi:
            return False
    return True

def getF2_main(F):
    F2 = []
    for h1 in H:
        if isHeaderInFlowkeys(F, h1):
            Flag = True
            for fj in F2:
                h2 = fj[0]
                if isHeaderMergeable(F, h1, h2):
                    fj.append(h1)
                    Flag = False
                    break
            if Flag:
                F2.append([h1])
    return F2
