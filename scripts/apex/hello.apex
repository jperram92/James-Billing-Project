/**
 * @description       : 
 * @author            : jamesperram@gmail.com
 * @group             : 
 * @last modified on  : 11-20-2024
 * @last modified by  : jamesperram@gmail.com
**/
/*
//Understanding logical operations
Boolean a = true;
Boolean b = false;

//Two logical Operations
// && AND operator
// || OR operator

system.debug('A: ' + a); //true
system.debug('B: ' + b); //false

//Logical AND Operations
//All conditions must be true
system.debug('Logical AND: ' + (a && b)); //false

//Logical OR Operations
//One condition must be true
system.debug('Logical OR' + (a || b)); //true

/*
system.debug(a && b);

&& is the logical AND operator.
It returns true only if both a and b are true.
If any one of them is false, the result is false.
So, when system.debug(a && b); outputs false, it means either a or b (or both) is false.
system.debug(a || b);

|| is the logical OR operator.
It returns true if at least one of a or b is true.
So, when system.debug(a || b); outputs true, it means either a, b, or both are true.
Summary:
AND (&&): All conditions must be true for the result to be true.
OR (||): At least one condition must be true for the result to be true.
*/

//Loops
for(Integer  i = 0; i <=10; i++) {
    System.debug('Multiple Numbers coming up: '+ i);
}
system.debug('After for loop finishes');

