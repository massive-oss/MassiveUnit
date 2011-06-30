package sub;
import massive.munit.Assert;
/**
 * ...
 * @author Mike Stead
 */

class ItemTest extends Item
{
	var item:ItemMock;
	
	public function new() 
	{
		super();
		item = new ItemMock();
	}
	
	@BeforeClass
	public function beforeClass():Void
	{
	}
	
	@AfterClass
	public function afterClass():Void
	{
	}
	
	@Before
	public function setup():Void
	{
	}
	
	@After
	public function tearDown():Void
	{
	}
	
	@TestDebug
	@Test
	public function testConstructor():Void
	{
		//throw "foo";
		Assert.isFalse(false);
	}
	
	@Test
	public function testBlah():Void
	{
		Assert.isTrue(true);
	}
}