#include <openssl/sha.h>
#include <zlib.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

void b64random(char *text, int length)
{
    const char chars[] = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789_/";
    int i;
    FILE *fp = fopen("/dev/urandom", "rb");
    if (fp == NULL) exit(1);
    fread(text, length, 1, fp);
    fclose(fp);
    for (i = 0; i < length; i++)
        text[i] = chars[text[i] % 64];
    text[i] = '\0';
}

void check_proof_of_work(char *salt)
{
    char text[128];
    strcpy(text, salt);
    char sha1[SHA_DIGEST_LENGTH];
    fgets(text + strlen(text), sizeof(text) - strlen(text), stdin);
    SHA1(text, strlen(text) - 1, sha1);

    if (sha1[0] != 0x12 || sha1[1] != 0x34 || sha1[2] != 0x56) {
        printf("Invalid PoW.\n");
        fflush(stdout);
        exit(1);
    }
    else {
        printf("Welcome!\n");
        fflush(stdout);
    }
}

void proof_of_work()
{
    char salt[16];
    b64random(salt, 8);
    printf("Send me a proof-of-work sha1(\"%s\" || stripLF(sent)) = 123456xxx...\n", salt);
    fflush(stdout);
    check_proof_of_work(salt);
}

int readdata(char *inbuf, int inbufsize)
{
    char buf[16];
    char len, lens;
    fgets(buf, sizeof(buf), stdin);
    if (atoi(buf) + 1 > inbufsize) {
        fprintf(stderr, "atoi(buf) + 1 > inbufsize\n");
        exit(1);
    }
    len = atoi(buf);
    lens = len + 1;
    
    char i;
    for (i = 0; i != lens; i++) {
        int c = fgetc(stdin);
        if (c < 0) exit(1);
        inbuf[i] = c;
    }
    inbuf[len] = '\0';
    return len;
}
void writedata(char *buf, char length)
{
    printf("%d\n", length);
    fwrite(buf, length, 1, stdout);
    fflush(stdout);
}

void l33t()
{
    char inbuf[128];
    char outbuf[128];
    struct {
        char len;
        z_stream z;
    } vars;
#if 0
    {
        int i;
        for (i = 0; i < 20; i++)
            fprintf(stderr, "%02x ", outbuf[138+i]);
        fprintf(stderr, "\n");
    }
#endif

    vars.z.zalloc = Z_NULL;
    vars.z.zfree = Z_NULL;
    vars.z.opaque = Z_NULL;
    
    while (!feof(stdin)) {
        vars.len = readdata(inbuf, sizeof(inbuf));
        if (strcmp(inbuf, "Bye") == 0) break;

        deflateInit(&vars.z, Z_DEFAULT_COMPRESSION);
        
        vars.z.avail_in = vars.len;
        vars.z.next_in = inbuf;
        vars.z.next_out = outbuf;
        vars.z.avail_out = compressBound(vars.len);
        deflate(&vars.z, Z_FINISH);
        if (vars.z.total_out > vars.len) {
            fprintf(stderr, "%ld > %d\n", vars.z.total_out, vars.len);
            exit(1);
        }
        
        writedata(outbuf, vars.z.total_out);
    }
}


int main()
{
    alarm(60);
    proof_of_work();
    l33t();
    return 0;
}
