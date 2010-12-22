import massive.munit.TestSuite;

import SampleTest;
import sub.ItemTest;

/**
 * Auto generated Test Suite for MassiveUnit.
 * Refer to munit command line tool for more information (haxelib run munit)
 */

class TestSuite extends massive.munit.TestSuite
{		

	public function new()
	{
		super();

		add(SampleTest);
		add(sub.ItemTest);
	}
}
