/**
 * Test class for RMSRequestEnvelope
 */
@isTest
public class RMSRequestEnvelopeTest {

    /*private static testmethod void testStructure1(){
        String sample = '{"header":{"messageId":"123","messageGroupId":"1234","messageRelatedId":"12345","createdTimestamp":"2016-04-08T09:00:00","expiryTimestamp":"2016-04-08T09:30:00","priority":4,"clientId":"P2PEligibilityCheck","clientSystemId":"P2PEligibilityCheck","channelType":"Online","requestor":[{"requestorId":"888","requestorType":"Staff","requestorIdType":"Staff","requestorGroupType":"requestorGroup"}],"location":[{"locationId":"Transport","locationType":"Branch"}],"extension":[{"name":"organisationCode","value":"${#TestCase#ext_val}"}]},"body":{"assessmentType":"P2PMimumStandardsEligibility","licenceParameter":{"id":"19246800","idType":"RoadsRegistrationAndLicencing","surname":"CAUCHI","dateOfBirth":"1985-02-07"}}}';
		RMSRequestEnvelope req = (RMSRequestEnvelope)JSON.deserializeStrict(sample, RMSRequestEnvelope.class);
        System.assert(req.header != null, 'Header not deserialized');
        System.assert(req.body != null, 'Body not deserialized');
        System.assert(req.header.messageId == '123', 'header message id not deserialized');
    }
    
    private static testmethod void testStructure2(){
        String sample = '{"header":{"messageId":"1234","messageGroupId":"1234","messageRelatedId":"12345","createdTimestamp":"2016-04-08T09:00:00","expiryTimestamp":"2016-04-08T09:30:00","priority":4,"clientId":"P2PEligibilityCheck","clientSystemId":"P2PEligibilityCheck","channelType":"Online","requestor":[{"requestorId":"888","requestorType":"Staff","requestorIdType":"Staff","requestorGroupType":"requestorGroup"}],"location":[{"locationId":"Transport","locationType":"Branch"}],"extension":[{"name":"organisationCode","value":" "}]},"body":{"assessmentType":"P2PMimumStandardsEligibility","licenceParameter":{"id":"0058II","idType":"RoadsRegistrationAndLicencing","surname":"BATEMANN","dateOfBirth":"1953-11-17"}}}';
		RMSRequestEnvelope req = (RMSRequestEnvelope)JSON.deserializeStrict(sample, RMSRequestEnvelope.class);
        System.assert(req.header != null, 'Header not deserialized');
        System.assert(req.body != null, 'Body not deserialized');
        System.assert(req.header.messageId == '1234', 'header message id not deserialized');
    }
    private static testmethod void testStructure3(){
        String sample = '{"header":{"messageId":"123","messageGroupId":"1234","messageRelatedId":"12345","createdTimestamp":"2016-04-08T09:00:00","expiryTimestamp":"2016-04-08T09:30:00","priority":4,"clientId":"P2PEligibilityCheck","clientSystemId":"P2PEligibilityCheck","channelType":"Online","requestor":[{"requestorId":"888","requestorType":"Staff","requestorIdType":"Staff","requestorGroupType":"requestorGroup"}],"location":[{"locationId":"Transport","locationType":"Branch"}],"extension":[{"name":"organisationCode","value":"Transp"}]},"body":{"assessmentType":"P2PMinimumStandardsAssessment","vehicleParameter":{"plateNumber":"SDJ011","plateType":"O","chassisOrVIN":5355}}}';
		RMSRequestEnvelope req = (RMSRequestEnvelope)JSON.deserializeStrict(sample, RMSRequestEnvelope.class);
        System.assert(req.header != null, 'Header not deserialized');
        System.assert(req.body != null, 'Body not deserialized');
        System.assert(req.header.messageId == '123', 'header message id not deserialized');
    }
    
	private static testmethod void testStructure4(){
        String sample = '{"header":{"messageId":"1234","messageGroupId":"1234","messageRelatedId":"12345","createdTimestamp":"2017-01-23T09:00:00","expiryTimestamp":"2017-01-23T09:30:00","priority":4,"clientId":"P2PEligibilityCheck","clientSystemId":"P2PEligibilityCheck","channelType":"Online","requestor":[{"requestorId":"888","requestorType":"Staff","requestorIdType":"Staff","requestorGroupType":"requestorGroup"}],"location":[{"locationId":"Transport","locationType":"Branch"}],"extension":[{"name":"organisationCode","value":"TRNSPT"}]},"body":{"assessmentType":"P2PMinimumStandardsAssessment","query":{"id":"17-04-001-287-TRNSPT"}}}';
		RMSRequestEnvelope req = (RMSRequestEnvelope)JSON.deserializeStrict(sample, RMSRequestEnvelope.class);
        System.assert(req.header != null, 'Header not deserialized');
        System.assert(req.body != null, 'Body not deserialized');
        System.assert(req.header.messageId == '1234', 'header message id not deserialized');
    }*/    
    
    

}