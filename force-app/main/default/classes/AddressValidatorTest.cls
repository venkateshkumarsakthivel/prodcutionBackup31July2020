@isTest
public class AddressValidatorTest {
	@isTest
    private static void serviceTest(){
                
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());        
        AddressValidator.Response res = AddressValidator.service(Label.DataSan_EndPoint + 'au/companyLookup?apiName=SearchByASICv201408&name=&config=%26includeHistoricalDetails%3Dn%26searchString=123546789' , 'GET', 'application/json', null, Label.DataSan_Key, 'application/json');            
        
        String actualValue = res.body;
        String expectedValue = '{"foo":"bar"}';
        System.assertEquals(actualValue, expectedValue);
        System.assertEquals(200, res.statusCode);		

    }
}