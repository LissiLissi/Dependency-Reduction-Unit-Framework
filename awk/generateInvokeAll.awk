# Copyright (C) 2020 Intel Corporation
# SPDX-License-Identifier: AGPL-3.0-or-later
# Input: List of all generated test files.  It is expected that each file contains the
# function: -- void call_File_< fileName > -- (without file extension)  This script generates the
# function void invokeAllTest().  The function calls all call_File_<fileName> functions.
# e.g. ls generated/* | awk -f generateInvokeAll.awk

BEGIN{
	print "/* This is file generated by eUnit, don't edit */"
	print "#include \"eUnit.h\"\n"
}


{
	n = split($0,filename,"[/.]");
	print "extern unsigned int __eUnitFile_" filename[n-1] "();"
	callFiles = callFiles "   numberOfFailedTests+=  __eUnitFile_"filename[n-1] "();\n"
}


END{
	print "\nunsigned int invokeAllTest()\n{"
	print "   unsigned int numberOfFailedTests = 0;"
	print "    MessageToDebugger(startTesting);"
	print callFiles
	print "    MessageToDebugger(finishAllTest);"
	print "    return numberOfFailedTests;"	
	print "}"
}
