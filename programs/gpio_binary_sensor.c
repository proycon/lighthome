#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <signal.h>
#include <string.h>
#include <lgpio.h>
#include <arpa/inet.h>

int halt = 0;
//state buffer (current state, previous state, state before that)
int state[3] = {-1,-1,-1};

void term(int signum)
{
   halt = 1;
}

void refresh(int signum)
{
   for (int i = 0; i < 3; i++) state[i] = -1;
}


unsigned get_revision(void) {
  FILE *fp;
  uint32_t n = 0;

  if ((fp = fopen("/proc/device-tree/system/linux,revision", "r"))) {
    if (fread(&n, sizeof(n), 1, fp) != 1) {
      fclose(fp);
      return 0;
    }
  }
  fclose(fp);
  return ntohl(n);
}

unsigned processor(void) {
     return (get_revision()>>12)&7;
}

int main(int argc, char *argv[]) {
    int pin = 0;
    int pull_mode = LG_SET_PULL_NONE;

    struct sigaction action;
    memset(&action, 0, sizeof(action));
    action.sa_handler = term;
    sigaction(SIGTERM, &action, NULL);

    struct sigaction action2;
    memset(&action, 0, sizeof(action2));
    action2.sa_handler = refresh;
    sigaction(SIGUSR1, &action2, NULL);
    sigaction(SIGUSR2, &action2, NULL);

    int handle;
    if (processor() == 4) {
        handle = lgGpiochipOpen(4);
    } else {
        handle = lgGpiochipOpen(0);
    }
    if (handle < 0) {
        fprintf(stderr, "Opening GPIO chip failed\n");
        return 1;
    }

    int opt;
    while ((opt = getopt(argc, argv, "p:udz")) != -1) {
        switch (opt) {
            case 'p':
                pin = atoi(optarg);
                break;
            case 'u':
                pull_mode = LG_SET_PULL_UP;
                break;
            case 'd':
                pull_mode = LG_SET_PULL_DOWN;
                break;
            case 'z':
                pull_mode = LG_SET_PULL_NONE; //default
                break;
            case '?':
                fprintf(stderr, "Unknown option: %c\n", optopt);
                return 1;
        }
    }

    if (pin == 0) {
        fprintf(stderr, "No pin number specified use -p with a BCM pin number\n");
        return 1;
    }

    lgGpioClaimInput(handle, pull_mode, pin);

    while (!halt) {
        state[0] = lgGpioRead(handle, pin);
        if ((state[0] == state[1]) && (state[1] != state[2])) {
            printf("%d\n", state[0]);
            fflush(stdout);
        }
        for (int i = 2; i > 0; i--) state[i] = state[i-1];
        lguSleep(0.06);
    }

    return 0;
}
