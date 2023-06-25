from os import path
import random

current_dir = path.dirname(__file__)
pattern_num = 100
reg = [0]*8
f1 = open(current_dir+'/'+'input.pattern','w')
f2 = open(current_dir+'/'+'output_golden.pattern','w')   

for i in range(pattern_num):
    RX = random.randrange(0,8)
    RY = random.randrange(0,8)
    RW = random.randrange(0,8)
    WEN = random.randrange(0,2)
    busW = random.randrange(0,256)
    WEN %= 2
    
    if(WEN and RW!=0):
        reg[RW] = busW
    
    busX_golden = reg[RX]
    busY_golden = reg[RY]
    
    f1.write(str(bin(RX)[2:].zfill(8))+'\n')
    f1.write(str(bin(RY)[2:].zfill(8))+'\n')
    f1.write(str(bin(RW)[2:].zfill(8))+'\n')
    f1.write(str(bin(WEN)[2:].zfill(8))+'\n')
    f1.write(str(bin(busW)[2:].zfill(8))+'\n')
    
    f2.write(str(bin(busX_golden)[2:].zfill(8))+'\n')
    f2.write(str(bin(busY_golden)[2:].zfill(8))+'\n')

f1.close()
f2.close()