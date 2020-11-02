    In this case we decided to implement a simple calculator whose primary function was to return the computed value for new operands and operators computing upon the previous result of the calculator. 
    To begin editing your customized kernel, it is essential to understand the data flow of inputs and output throughout the kernel. The data from the web front end is transferred to the kernel by means of the |in/trans$data variable which consists of 512 bits. In our example we pass the first 32 bits with the value for the next operand to be operated with the previous result and the next 4 bits are reserved for the operator variable which decides which operation is to be conducted between the 2 given operands. The rest is 0 padded and the variables are extracted as follows in the |in as follows:- 
$val2 = |in/trans$data[31:0];
$op =  |in/trans$data[34:32];

    Finally, the output data is transferred out through the |out/trans$data variable in a similar manner to which the input is accepted by the kernel. The final computed output stored in the variable $output, is then transferred to $data in |out/trans as follows:- 
|out/trans$data[31:0] = $output;


    This completes the transfer of data from the input and output side of the kernel respectively. To run the application locally, one must shift to the directory /apps/calculator/build and run the command - make launch.
Once this is done, it opens a Web Server that can be accessed by entering http://localhost:8888 on your local browser. To stop the application from running, a simple ^C is enough. 

Ideally the web front end for this calculator will be designed in a way such that the user will be able to provide 2 primary inputs, one being the new operand value that the present result with operate with, and the operator, which will accordingly provide the new result using the previous result and the new operand value. A guide will be put up to indicate the different operators that this code can handle, and how to go about using them. Upon running, the output box will produce the necessary output back to the user, and this will be further used in successive iterations of the calculator and so forth.



