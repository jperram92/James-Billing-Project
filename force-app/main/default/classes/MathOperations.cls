/**
 * @description       : 
 * @author            : jamesperram@gmail.com
 * @group             : 
 * @last modified on  : 11-20-2024
 * @last modified by  : jamesperram@gmail.com
**/
public class MathOperations {
    
    // Method to add two numbers
    public static Integer addNumbers(Integer a, Integer b) {
        return a + b;
    }

    // Method to subtract two numbers
    public static Integer subtractNumbers(Integer a, Integer b) {
        return a - b;
    }

    // Method to multiply two numbers
    public static Integer multiplyNumbers(Integer a, Integer b) {
        return a * b;
    }

    // Method to divide two numbers
    public static Decimal divideNumbers(Decimal a, Decimal b) {
        if (b == 0) {
            throw new MathException('Cannot divide by zero.');
        }
        return a / b;
    }

    // Method to calculate the square of a number
    public static Integer squareNumber(Integer a) {
        return a * a;
    }

    // Method to calculate the square root of a number
    public static Decimal squareRoot(Decimal a) {
        if (a < 0) {
            throw new MathException('Cannot calculate the square root of a negative number.');
        }
        return Decimal.valueOf(Math.sqrt(a.doubleValue()));
    }

    // Method to calculate Pi to a specified number of decimal places
    public static Decimal getPi(Integer decimalPlaces) {
        if (decimalPlaces < 0) {
            throw new MathException('Decimal places must be non-negative.');
        }
        Decimal pi = 3.141592653589793;
        return pi.setScale(decimalPlaces, RoundingMode.HALF_UP);
    }

    // Method to calculate the power of a number (a^b)
    public static Decimal power(Decimal base, Integer exponent) {
        return Decimal.valueOf(Math.pow(base.doubleValue(), exponent));
    }

    // Method to calculate modulus
    public static Integer modulus(Integer a, Integer b) {
    if (b == 0) {
        throw new MathException('Cannot calculate modulus with divisor as zero.');
    }
    Integer quotient = a / b; // Integer division
    return a - (quotient * b); // Modulus calculation
}
    
    // Method to calculate the factorial of a number
    public static Integer factorial(Integer n) {
        if (n < 0) {
            throw new MathException('Factorial is not defined for negative numbers.');
        }
        Integer result = 1;
        for (Integer i = 1; i <= n; i++) {
            result *= i;
        }
        return result;
    }
}