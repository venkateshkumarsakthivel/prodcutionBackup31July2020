global with sharing class ACNandABNValidation {
	private enum ValidationType {ACN, ABN}
    
    static final List<Long> ACN_WEIGHTS = new List<Long>{8,7,6,5,4,3,2,1};
    static final List<Long> ABN_WEIGHTS = new List<Long>{10,1,3,5,7,9,11,13,15,17,19};

    webservice static Boolean ValidateACN(String acnString) {
        acnString = getNonBlankNumericStringWithoutWhitespace(acnString);
        if(acnString == null) {
            return false;
        }

        if(acnString.length() != 9) {
            return false;
        }

        Integer strLength = acnString.length();
        Long givenCheck = Long.valueOf(acnString.substring(strLength - 1,strLength));
        Long acnWeightSum = calcWeightingSum(ValidationType.ACN, acnString);
        Long modTenRemainder = Math.mod(acnWeightSum, 10);
        Long calcCheck = (modTenRemainder == 0) ? 0 : (10 - modTenRemainder);
        if(calcCheck != givenCheck) {
            return false;
        }

        return true;
    }


    webservice static Boolean ValidateABN(String abnString) {
         System.debug('abn string'+abnString);
        abnString = getNonBlankNumericStringWithoutWhitespace(abnString);
        if(abnString == null) {
            return false;
        }

        if(abnString.length() != 11) {
            return false;
        }

        if(abnString.substring(0,1) == '0') {
            return false;
        }
		System.debug('abn string 1'+abnString);
        String pos1Less1 = String.valueOf(Long.valueOf(abnString.substring(0,1))-1);
        String modifiedABN = String.valueOf(pos1Less1 + abnString.substring(1));
        Long abnWeightingSum = calcWeightingSum(ValidationType.ABN, modifiedABN);
        Long modEightyNineRemainder = Math.mod(abnWeightingSum, 89);
        if(modEightyNineRemainder != 0) {
            return false;
        }

        return true;
    }


    webservice static Boolean ValidateARBN(String arbnString) {
        return ValidateACN(arbnString);
    }


    private static Long calcWeightingSum(ValidationType valType, String theNumString) {
        List<Long> weightList = 
            (valType == ValidationType.ACN) ? ACN_WEIGHTS : ABN_WEIGHTS;
        Long weightingSum = 0;

        Integer startIndex = 0;
        Integer endIndex = (valType == ValidationType.ACN ? 7 : 10);

        for(Integer i = startIndex; i <= endIndex; i++) {
            weightingSum += 
                ( Long.valueOf(theNumString.substring(i,i+1) ) * weightList[i]);
        }
        
        return weightingSum;
    }


    private static String getNonBlankNumericStringWithoutWhitespace(String theString) {
        if(String.isBlank(theString)) {
            return null;
        }

        theString = theString.deleteWhitespace();

        if(!theString.isNumeric()) {
            return null;
        }

        return theString;
    }
}