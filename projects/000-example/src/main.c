/*
 * Number stats: reads whole numbers from standard input until the input
 * ends, then prints how many there were, their sum, the smallest and the
 * largest.
 *
 * This is the reference example for the project layout. It is not a ticket.
 */
#include <stdio.h>

int main(void) {
    int value;
    int count = 0;
    long sum = 0;
    int min = 0;
    int max = 0;
    int result;

    while ((result = scanf("%d", &value)) == 1) {
        if (count == 0 || value < min) {
            min = value;
        }
        if (count == 0 || value > max) {
            max = value;
        }
        sum += value;
        count++;
    }

    /* scanf returns 0 when the next input is not a number, and EOF when the
     * input has ended. Only EOF means everything was read. */
    if (result != EOF) {
        printf("error: input contains something that is not a whole number\n");
        return 1;
    }
    if (count == 0) {
        printf("error: no numbers given\n");
        return 1;
    }

    printf("count: %d\n", count);
    printf("sum: %ld\n", sum);
    printf("min: %d\n", min);
    printf("max: %d\n", max);
    return 0;
}
