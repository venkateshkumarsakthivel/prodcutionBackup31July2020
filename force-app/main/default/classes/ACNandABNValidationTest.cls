@IsTest
private class ACNandABNValidationTest {

    @IsTest
    static void testACNValidation() {   
        System.assertEquals(true,  ACNandABNValidation.ValidateACN('010749961'));   //Valid #
        System.assertEquals(false, ACNandABNValidation.ValidateACN('123456'));      //# too short  
        System.assertEquals(false, ACNandABNValidation.ValidateACN('123456789'));   //# right length, but invalid
        System.assertEquals(false, ACNandABNValidation.ValidateACN('a2c4e6h8j'));   //# contains non-numeric
    }

    @IsTest
    static void testARBNValidation() {
        System.assertEquals(true,  ACNandABNValidation.ValidateARBN('010749961'));   //Valid #
        System.assertEquals(false, ACNandABNValidation.ValidateARBN('123456'));      //# too short  
        System.assertEquals(false, ACNandABNValidation.ValidateARBN('123456789'));   //# right length, but invalid
        System.assertEquals(false, ACNandABNValidation.ValidateARBN('a2c4e6h8j'));   //# contains non-numeric
    }

    @IsTest
    static void testABNValidation() {
        System.assertEquals(true,   ACNandABNValidation.ValidateABN('53004085616')); //Valid #
        System.assertEquals(false,  ACNandABNValidation.ValidateABN('123456'));      //# too short  
        System.assertEquals(false,  ACNandABNValidation.ValidateABN('12345678911')); //# right length, but invalid
        System.assertEquals(false,  ACNandABNValidation.ValidateABN('a2c4e6h8j11')); //# contains non-numeric
    }

}