#include <stdio.h>

int main() {
    int num1, num2;
    char operator;
    int result;

    printf("key in num1:");
    scanf("%d", &num1);

    printf("key in operator(+, -, *, /):");
    scanf(" %c", &operator);

    printf("key in num2:");
    scanf("%d", &num2);

    if (operator == "+") {
        result = num1 + num2;
    } else if (operator == "-") {
        result = num1 - num2;
    } else if (operator == "*") {
        result = num1 * num2;
    } else if (operator == "/") {
        if (num2 != 0) {
            result = num1 / num2;
        } else {
            printf("divisor cannot be zero! \n");
            return 0;
        }
    } else {
        printf("Invalid operator symbol! \n");
        return 0;
    }

    printf("result: %d\n", result);
    
    return 0;
}