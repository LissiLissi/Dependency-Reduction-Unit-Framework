# Dependency-Reduction-Unit-Framework

# Dependency-Reduction-Unit-Framework for C/C++ -Projects 
For further information’s see the wiki! 

To do your first steps it is recommended to read the “[getting started](https://github.com/diridari/EmbeddedTesting/wiki/Getting-Started-with-eUnit)”!

clone: `git clone --recurse-submodules https://github.com/diridari/EmbeddedTesting.git`

## OS support
This application has been developed on a Ubuntu 18.4 LTS systems. It also has been tested on a Windows-10 System but does not support all feature (rescue result buffer if gdbMann gets interrupted by CTRL+C) 


## Goals
This application intended to enable dependency reduction in C-projects. Here it is often not possible to create Unit-Tests, due to irresolvable dependencies.
One reason for this might be a high number of function calls within the same source file.
This system allows reduction these dependencies by use the debugger.

## Director structure
 * [eUnit](https://github.com/diridari/EmbeddedTesting/wiki/eUnit)              :   Framework (running on the target) that communicate with the GDBManipulator 
 * [GDB Manipulator(gdbMann)](https://github.com/diridari/EmbeddedTesting/wiki/GDBManipulator)    :   Application running on the host machine to reduce the Dependency’s and evaluate the test results
 * awk               :   some scripts to make [test creation](https://github.com/diridari/EmbeddedTesting/wiki/Test-Syntax-and-Test-creation) easier 
 * examples          :   some examples test project for STM32 or host systems 

## Requirements
In order to use this system it is necessary to have a working update and debug environment(e.g gdb). This enables to flash and debug the target by the cli. 

## System overview
For embedded/remote devices 
![Alt text](doc/pic/system.png?raw=true "structure")
###  Required components
 * GDB-Server: 
Is the target is an embedded device or a remote device, a GDB-Server is required to establish the connection to the target.
 * Debugger Probe: 
Is the target is an embedded device, a debugger probe  is required to connect the GDB-Server to the target.
 * GDB-Client
 * Elf-File:  
It is required to read the memory of the Target in order to reduce dependencies and evaluate the test results. The GDB-client can access these via the elf-file. 

 * Program adjustments: The targets application has to be modified: 
Copy the “eUnit” Folder into you Project and create an ‘invokeAllTest ()’ function which calls each test-group and test-case. For further information’s see the wiki entry. 

## Setup
In order to work properly, the target needs the “[eUnit](https://github.com/diridari/EmbeddedTesting/wiki/eUnit)”-Framework. Copy and paste it into your project and call the ‘invokeAllTest()’ function after system setup. 
Redefine the ‘invokeAllTest()’ function and create some Test-Groups with their Test-Cases. Since the function is a weak one this is possible.
The function ‘invokeAllTest()’ calls each group and each group calls its test-cases.

For gTest like syntax see [test creation](https://github.com/diridari/EmbeddedTesting/wiki/Test-Syntax-and-Test-creation) 

The function ‘invokeAllTest()’ blocks until the “[GDB Manipulator(gdbMann)](https://github.com/diridari/EmbeddedTesting/wiki/GDBManipulator)” application connects with the target and the setup of the test configuration is complete.

After the execution of all tests is done the target continues with the code after the ‘invokeAllTest()’ function in "runMode" or termintaes in "testMode". see :"[gdbMann arguments](https://github.com/diridari/EmbeddedTesting/wiki/gdbMann_Program-arguments#--runmode)"  

### [Test-Case Generation]((https://github.com/diridari/EmbeddedTesting/wiki/Test-Syntax-and-Test-creation))
An AWK-Parser allows to create gtest-like testcases and also generates the CallGroup and ‘invokeAllTest()’ functions. 
For further information see the readme in the awk-folder or the [wiki]((https://github.com/diridari/EmbeddedTesting/wiki/Test-Syntax-and-Test-creation)). 
### gdbMann
The "GDB-Manipulaton"-application([gdbMann]((https://github.com/diridari/EmbeddedTesting/wiki/GDBManipulator))) connects with configures the target depending to the [runMode](https://github.com/diridari/EmbeddedTesting/wiki/gdbMann_Program-arguments#--runmode) and [testLevel](https://github.com/diridari/EmbeddedTesting/wiki/gdbMann_Program-arguments#--testlevel). Then its executes all tests and evaluates the test-result. 

The applications requires at least two [command arguments](https://github.com/diridari/EmbeddedTesting/wiki/gdbMann_Program-arguments): 

* -elf or -bin
* -c or --client

#### Elf-File Location 

    "-elf <location>                 path to file

For further informatiosn see the [wiki](https://github.com/diridari/EmbeddedTesting/wiki/gdbMann_Program-arguments#-elf)
#### GDB-Client
location of the corresponding GDB-Client 

     -c <command to call>   or  --client <command to call> command to call the gdb-client
     
For further informatiosn see the [wiki](https://github.com/diridari/EmbeddedTesting/wiki/gdbMann_Program-arguments#--client)

#### GDB-Server
For embdedded applications it is alos possible to start automatically the gdb server. Hear it is nessesary to set as command the entire server call. 

If the call contains spaces it is possible to surround the entire command with quotation marks (")


    -s <command>  or --server <command>

e.g.
         
     -s "/opt/Atollic_TrueSTUDIO_for_STM32_x86_64_9.0.0/Servers/ST-LINK_gdbserver/ST-LINK_gdbserver -d"  
       
#### GDB-Port
Change the default port (61234) from gdb-client to gdb-server:

    -p <port>` or `--port <port>

#### Test-Level
Change the amount of test-Information (and therefore change the test-execution time):
It is possible to select between four different test-levels by : 

    -t <level>` or `--testLevel <level>
    
The levels are: 
* "justSuccess" : boolean information about the test-status (failed/success )
* "testName" : (default) justSuccess + name and group of the executed test
* "testResults":  testName + result and expected value of an failed test
* "lineNumber": testResults + linenumber of the failed tests

#### Flash the Elf-File
Flash the elf file before executing the tests.

    -f or --flash

For further Information’s about the arguments see the corresponding [wiki-entry](https://github.com/diridari/EmbeddedTesting/wiki/gdbMann_Program-arguments). 

## Mocks and Stubs
#### Example signature 
` int add5(int a);
int returnX(int a);`
### Mocks
 **must have the same signature like add5!!**

Mocks have access to the same variables as the originating function
Usage:

    whenMock(add5,returnX);

If add5()  is called it will be replaced by returnX().
returnX()  must have the same signature.
### Stubs
**Stubs do not require the same signature, but the same return value**
Stubs allow returning every expression as long as the expression has the same return value as the origin function.

    whenStub(add5,"100");
    whenStub(add5,"50 +50");
    whenStub(add5,"100");
    whenStub(add5,"add(5,5)");

***
# Getting Started with eUnit

This document descripts how to do the first steps with [eUnit](https://github.com/diridari/EmbeddedTesting/wiki/eUnit) with dependeny reduction. It is divided into two Parts:

    using the examples
    use in your own projects

The [eUnit](https://github.com/diridari/EmbeddedTesting/wiki/eUnit)-Framework also allows to use a "Selftest-Mode" mode without the use of the [GDB Manipulator(gdbMann)](https://github.com/diridari/EmbeddedTesting/wiki/GDBManipulator).
Using the provided examples
## Requirements

In order to use this system it is necessary to flash and debug the target by the GDB. This example is using the “Atollic TrueSTUDIO for STM32”. Once installed its provide an working flash and update mechanism. But feel free to use your own build and debug environment.

## Using an Example

    build the whole target project
    build gdbMann 

Now you need the commands to:

    command to call the GDB-Server (alternative if the gdb-Server is already runing in background skip this command )
    command to call the GDB-Client
    Elf-File location

If you are using the Atollic true studio those applications are per default at : ‘/opt/Atollic_TrueSTUDIO_for_STM32_x86…’

for example you can use: 
     -s "/opt/Atollic_TrueSTUDIO_for_STM32_x86_64_9.0.0/Servers/ST-LINK_gdbserver/ST-LINK_gdbserver -d" –c /opt/Atollic_TrueSTUDIO_for_STM32_x86_64_9.0.0/ARMTools/bin/arm-atollic-eabi-gdb –elf /home/testUser/git/EmbeddedTesting/examples/Stm32F4/Debug/EmbeddedTesting.elf

If the Target is not jet flashed you need additional to add ‘-f’ to flash the target with the elf-file For Further information’s see the Wiki entry: “Program Arguments”

Run the Application ‘[gdbMann](https://github.com/diridari/EmbeddedTesting/wiki/GDBManipulator)’ with those [arguments](https://github.com/diridari/EmbeddedTesting/wiki/gdbMann_Program-arguments). e.g.

    ./gdbMann -elf <elfFile> -s "/opt/Atollic_TrueSTUDIO_for_STM32_x86_64_9.0.0/Servers/ST-LINK_gdbserver/ST-LINK_gdbserver -d" -c /opt/Atollic_TrueSTUDIO_for_STM32_x86_64_9.0.0/ARMTools/bin/arm-atollic-eabi-gdb

Now you should see the test output like:

      [ RUN      ]        
      [       OK ] EQ_SUCCESS::NEQ_SUCCESS
     
     ….
     
      [  FAILED  ] MockSucces::NEQ_FAIL        
                    (int32) Expected: 0	not to be equals to : 0        
     …        
      [ RUN      ]        
      [  FAILED  ] MockSucces::NEQ_FAIL        
     				     is<3> :	 01 02 03   |  ...        
     				 should<3> :	 02 ** **   |  ...        
     ….        
     test result : test run : 23  	 test failed : 9	 errors : 0         
     buffer reads : 4


 ## Different Test-Levels:
 To speedup the testcases there are some Test-Levels. Each additional level provides more information about the failed test but decrease the test execution. It is possible the change the testlevel with the program argument ‘-t ’ or –testLevel arguments are:

    "justSuccess" : boolean information about the test-status
    "testName" : (default) + name and group of the executed test
    "testResults" + result and expected value of an failed test
    "lineNumber" + number of the failed test

## Add eUnit into your Projects

To add ‘[eUnit](https://github.com/diridari/EmbeddedTesting/wiki/eUnit)’ to you own projects it is just necessary to copy the folder ‘/eUnit’ into you project and call the ‘invokeAllTest()’ from the main. 
To create your own tests each test must get called in the ‘invokeAllTest()’ Function.
See: [Test creation](https://github.com/diridari/EmbeddedTesting/wiki/Test-Syntax-and-Test-creation)

It is highly recommended to generate those functions with the provided ‘awk’-script. Further information’s are provided in the wiki entry: “Test Syntax and Test creation”
