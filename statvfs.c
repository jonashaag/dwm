#include <stdio.h>
#include <sys/statvfs.h>

int main(int argc, char** argv) {
  if(argc != 2)
    return 1;

  struct statvfs stat;
  if(statvfs(argv[1], &stat) < 0)
    return 2;

  printf("%.1fG\n", ((double)stat.f_bavail)*stat.f_bsize/(1024*1024*1024));

  return 0;
}
