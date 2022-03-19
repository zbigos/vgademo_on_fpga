with open("mikoto.gds" ,"r") as f:
    with open("mikoto_scaled.gds", "w") as fo:
        for l in f.read().split("\n"):
            if ":" in l:
                try:
                    lsp = l.split(":")
                    if len(lsp) != 2:
                        fo.write(l + "\n")                        
                    else:
                        if lsp[0][0] == 'X':
                            ndim = int(2 * int(lsp[0][2:]))
                            mdim = int(2 * int(lsp[1]))
                            fo.write("XY ",str(ndim), ": ", str(mdim), "\n")
                            
                        else:
                            ndim = int(2 * int(lsp[0]))
                            mdim = int(2 * int(lsp[1]))
                            fo.write(str(ndim), ": ", str(mdim), "\n")
                except:
                    fo.write(l + '\n')
            else:
                fo.write(l + "\n")