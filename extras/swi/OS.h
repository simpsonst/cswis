#undef OS_WriteI
#define OS_WriteI(C)  (0x100+(unsigned char)(C))
#undef XOS_WriteI
#define XOS_WriteI(C) (0x20100+(unsigned char)(C))
