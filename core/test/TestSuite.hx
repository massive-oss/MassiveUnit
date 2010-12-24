/**************************************** ****************************************
 * Copyright 2010 Massive Interactive. All rights reserved.
 * 
 * Redistribution and use in source and binary forms, with or without modification, are
 * permitted provided that the following conditions are met:
 * 
 *    1. Redistributions of source code must retain the above copyright notice, this list of
 *       conditions and the following disclaimer.
 * 
 *    2. Redistributions in binary form must reproduce the above copyright notice, this list
 *       of conditions and the following disclaimer in the documentation and/or other materials
 *       provided with the distribution.
 * 
 * THIS SOFTWARE IS PROVIDED BY MASSIVE INTERACTIVE ``AS IS'' AND ANY EXPRESS OR IMPLIED
 * WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND
 * FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL MASSIVE INTERACTIVE OR
 * CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
 * CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
 * SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON
 * ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
 * NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
 * ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 * 
 * The views and conclusions contained in the software and documentation are those of the
 * authors and should not be interpreted as representing official policies, either expressed
 * or implied, of Massive Interactive.
 */
import massive.munit.TestSuite;

import massive.munit.AssertionExceptionTest;
import massive.munit.AssertTest;
import massive.munit.async.AsyncDelegateTest;
import massive.munit.async.AsyncFactoryTest;
import massive.munit.async.AsyncTimeoutExceptionTest;
import massive.munit.async.MissingAsyncDelegateExceptionTest;
import massive.munit.MUnitExceptionTest;
import massive.munit.TestClassHelperTest;
import massive.munit.TestResultTest;
import massive.munit.TestRunnerTest;
import massive.munit.TestSuiteTest;
import massive.munit.UnhandledExceptionTest;

/**
 * Auto generated Test Suite for MassiveUnit.
 * Refer to munit command line tool for more information (haxelib run munit)
 */

class TestSuite extends massive.munit.TestSuite
{		

	public function new()
	{
		super();

		add(massive.munit.AssertionExceptionTest);
		add(massive.munit.AssertTest);
		add(massive.munit.async.AsyncDelegateTest);
		add(massive.munit.async.AsyncFactoryTest);
		add(massive.munit.async.AsyncTimeoutExceptionTest);
		add(massive.munit.async.MissingAsyncDelegateExceptionTest);
		add(massive.munit.MUnitExceptionTest);
		add(massive.munit.TestClassHelperTest);
		add(massive.munit.TestResultTest);
		add(massive.munit.TestRunnerTest);
		add(massive.munit.TestSuiteTest);
		add(massive.munit.UnhandledExceptionTest);
	}
}
