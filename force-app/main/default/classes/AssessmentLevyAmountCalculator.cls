public with sharing class AssessmentLevyAmountCalculator {
    
    public static String annualEstimatesFewerThan150 = '150 or fewer';
    public static String annualEstimatesBetween151and400 = '151 to 400';
    public static String annualEstimatesBetween401and600 = '401 to 600';
    public static String annualEstimatesOver600 = 'Over 600';
    
    private static Map<Id, Boolean> tprVsBspAuth;
    private static Map<Id, Boolean> tprVsTspAuth;
    
    public static void calculate(List<Assessment__c> listAssessments, Boolean isTrueUpdateStatus) {
        checkForAuths(listAssessments);
        
        Map<String, List<Assessment__c>> tprVsAssessmentsMap = previousAssessments(listAssessments);  
        System.debug('tprVsAssessmentsMap '+tprVsAssessmentsMap);
        
        List<Passenger_Service_Transaction_Bands__mdt> passesngerServiceTransactionBandsMDT = [SELECT Id, MasterLabel, Default_Estimate_if_NULL_Return__c, Lower_Hold_Tolerance__c, Upper_Hold_Tolerance__c FROM Passenger_Service_Transaction_Bands__mdt];
        Map<String, Decimal> annualEstimateBandVsLowerHoldTolerance = new Map<String, Decimal>();
        Map<String, Decimal> annualEstimateBandVsUpperHoldTolerance = new Map<String, Decimal>();
        
        for(Passenger_Service_Transaction_Bands__mdt record : passesngerServiceTransactionBandsMDT) {
            annualEstimateBandVsLowerHoldTolerance.put(record.MasterLabel, record.Lower_Hold_Tolerance__c);
            annualEstimateBandVsUpperHoldTolerance.put(record.MasterLabel, record.Upper_Hold_Tolerance__c);
        }
        Map<String,Annual_Estimates_And_Trip_Count__mdt> annualEstimateVsTripCounts = new Map<String,Annual_Estimates_And_Trip_Count__mdt>();
        for(Annual_Estimates_And_Trip_Count__mdt tripCounts : [SELECT Id, MasterLabel,BSP_Trip_Count__c, TSP_Trip_Count__c, BSP_TSP__c
                                                               FROM Annual_Estimates_And_Trip_Count__mdt]) {
                                                                   annualEstimateVsTripCounts.put(tripCounts.MasterLabel,tripCounts);
                                                               }
        try {
            
            System.debug(LoggingLevel.INFO, '== AssessmentLevyAmountCalculator - scope size ==' + listAssessments.size());
            
            for(Assessment__c assessmentRecord : listAssessments) {
                System.debug('assessmentId: '+assessmentRecord.Id);
                Decimal totalTripCount = 0;
                if(assessmentRecord.BSP_Transaction_Count__c != null && assessmentRecord.TSP_Transaction_Count__c != null) {
                    totalTripCount = assessmentRecord.BSP_Transaction_Count__c + assessmentRecord.TSP_Transaction_Count__c;
                } else if(assessmentRecord.BSP_Transaction_Count__c != null) {
                    totalTripCount = assessmentRecord.BSP_Transaction_Count__c;
                } else if(assessmentRecord.TSP_Transaction_Count__c != null) {
                    totalTripCount = assessmentRecord.TSP_Transaction_Count__c;
                }
                
                if(assessmentRecord.Manual_Assessment_Required__c == 'Yes') {
                    
                    if(isTrueUpdateStatus) {
                        assessmentRecord = updateAssessmentAsHeld(assessmentRecord);
                    } 
                    
                    assessmentRecord.Total_Levy_Amount__c = assessmentRecord.Levy__c * totalTripCount; 
                    assessmentRecord.BSP_Levy_Amount__c = assessmentRecord.BSP_Transaction_Count__c;
                    assessmentRecord.TSP_Levy_Amount__c = assessmentRecord.TSP_Transaction_Count__c;
                    
                } else if(assessmentRecord.Manual_Assessment_Required__c == 'No') {
                    
                    //To check if "Rebate Approval Date" is the anniversary month or not, 
                    //subtract 1 month from Rebate Approval Date and match this month with levy period month
                    Integer levyPeriodAnniversaryMonth = 0;
                    if(assessmentRecord.Rebate_Approval_Date__c != NULL) {
                        levyPeriodAnniversaryMonth = assessmentRecord.Rebate_Approval_Date__c.addMonths(-1).month();
                    }
                    Integer levyPeriodMonth = assessmentRecord.Period_End_Date__c.month();
                    if(assessmentRecord.Exemption_Approved__c) {
                        
                        if(isTrueUpdateStatus) {
                            assessmentRecord = updateAssessmentAsAssessed(assessmentRecord, false);
                        }
                        
                        assessmentRecord.Total_Levy_Amount__c = 0;
                        assessmentRecord.BSP_Levy_Amount__c = 0;
                        assessmentRecord.TSP_Levy_Amount__c = 0;
                        
                    } 
                    else if(assessmentRecord.Exemption_Approved__c == false
                              && assessmentRecord.Annual_Estimates__c == annualEstimatesFewerThan150)  {
                                  
                                  if(assessmentRecord.BSP_Transaction_Count__c == null && assessmentRecord.TSP_Transaction_Count__c == null) {
                                      
                                      if(isTrueUpdateStatus) {
                                          assessmentRecord = updateAssessmentAsAssessed(assessmentRecord, true);
                                      } 
                                      if(annualEstimateVsTripCounts.containsKey(assessmentRecord.Annual_Estimates__c)) {
                                          if(assessmentRecord.Taxpayer_Registration__r.Taxi_Service_Provider_Number__c != null &&
                                             assessmentRecord.Taxpayer_Registration__r.Booking_Service_Provider_Number__c != null ) {
                                                 
                                                 assessmentRecord.BSP_Transaction_Count__c = annualEstimateVsTripCounts.get(assessmentRecord.Annual_Estimates__c).BSP_Trip_Count__c;
                                                 assessmentRecord.TSP_Transaction_Count__c = annualEstimateVsTripCounts.get(assessmentRecord.Annual_Estimates__c).TSP_Trip_Count__c;
                                                 
                                             } else if(assessmentRecord.Taxpayer_Registration__r.Booking_Service_Provider_Number__c != null) {
                                                 
                                                 assessmentRecord.BSP_Transaction_Count__c = annualEstimateVsTripCounts.get(assessmentRecord.Annual_Estimates__c).BSP_TSP__c;
                                                 
                                             } else if(assessmentRecord.Taxpayer_Registration__r.Taxi_Service_Provider_Number__c != null) {
                                                 
                                                 assessmentRecord.TSP_Transaction_Count__c = annualEstimateVsTripCounts.get(assessmentRecord.Annual_Estimates__c).BSP_TSP__c;
                                                 
                                             }
                                      }
                                      /*
                                        assessmentRecord.Total_Levy_Amount__c = 0;
                                        assessmentRecord.BSP_Levy_Amount__c = 0;
                                        assessmentRecord.TSP_Levy_Amount__c = 0;*/
                                      
                                  } else if(totalTripCount > 0 && totalTripCount <= 150) {
                                      
                                      if(isTrueUpdateStatus) {
                                          assessmentRecord = updateAssessmentAsAssessed(assessmentRecord, false);
                                      }
                                      
                                      assessmentRecord.Total_Levy_Amount__c = assessmentRecord.Levy__c * totalTripCount;
                                      assessmentRecord.BSP_Levy_Amount__c = assessmentRecord.BSP_Transaction_Count__c;
                                      assessmentRecord.TSP_Levy_Amount__c = assessmentRecord.TSP_Transaction_Count__c;
                                      
                                  } else {
                                      
                                      if(isTrueUpdateStatus) {
                                          assessmentRecord = updateAssessmentAsAssessed(assessmentRecord, false);
                                      }
                                      
                                      assessmentRecord.Total_Levy_Amount__c = assessmentRecord.Levy__c * totalTripCount;
                                      assessmentRecord.BSP_Levy_Amount__c = assessmentRecord.BSP_Transaction_Count__c;
                                      assessmentRecord.TSP_Levy_Amount__c = assessmentRecord.TSP_Transaction_Count__c;
                                  }
                              } 
                    else if(assessmentRecord.Rebate_Approved__c && levyPeriodAnniversaryMonth != levyPeriodMonth) {
                        
                        if(isTrueUpdateStatus) {
                            assessmentRecord = updateAssessmentAsAssessed(assessmentRecord, false);
                        }
                        
                        assessmentRecord.Total_Levy_Amount__c = 0;
                        assessmentRecord.BSP_Levy_Amount__c = 0;
                        assessmentRecord.TSP_Levy_Amount__c = 0;
                        
                    }else if(assessmentRecord.Rebate_Approved__c 
                            && levyPeriodAnniversaryMonth == levyPeriodMonth 
                            && (assessmentRecord.Annual_Estimates__c == annualEstimatesBetween151and400
                                || assessmentRecord.Annual_Estimates__c == annualEstimatesBetween401and600)){
                                    
                            if(totalTripCount > 0 && totalTripCount <= 150) {
                                if(isTrueUpdateStatus) {
                                    assessmentRecord = updateAssessmentAsAssessed(assessmentRecord, false);
                                }
                                
                                assessmentRecord.Total_Levy_Amount__c = 0;
                                assessmentRecord.BSP_Levy_Amount__c = 0;
                                assessmentRecord.TSP_Levy_Amount__c = 0;
                                
                            }
                            else if((totalTripCount >= 151 && totalTripCount <= 400)) {
                                
                                if(isTrueUpdateStatus) {
                                    assessmentRecord = updateAssessmentAsAssessed(assessmentRecord, false);
                                }
                                
                                assessmentRecord.Total_Levy_Amount__c = 150;
                                
                                if(hadTSPAuthorisation(assessmentRecord) && hadBSPAuthorisation(assessmentRecord)) {
                                    assessmentRecord.TSP_Levy_Amount__c = 75;
                                    assessmentRecord.BSP_Levy_Amount__c = 75;
                                } else if(hadTSPAuthorisation(assessmentRecord)) {
                                    assessmentRecord.TSP_Levy_Amount__c = 150;
                                    assessmentRecord.BSP_Levy_Amount__c = 0;
                                } else if(hadBSPAuthorisation(assessmentRecord)) {
                                    assessmentRecord.TSP_Levy_Amount__c = 0;
                                    assessmentRecord.BSP_Levy_Amount__c = 150;
                                }
                            } 
                            else if((totalTripCount >= 401 && totalTripCount <= 600)) {
                                
                                if(isTrueUpdateStatus) {
                                    assessmentRecord = updateAssessmentAsAssessed(assessmentRecord, false);
                                }
                                
                                assessmentRecord.Total_Levy_Amount__c = 400;
                                
                                if(hadTSPAuthorisation(assessmentRecord) && hadBSPAuthorisation(assessmentRecord)) {
                                    assessmentRecord.TSP_Levy_Amount__c = 200;
                                    assessmentRecord.BSP_Levy_Amount__c = 200;
                                } else if(hadTSPAuthorisation(assessmentRecord)) {
                                    assessmentRecord.TSP_Levy_Amount__c = 400;
                                    assessmentRecord.BSP_Levy_Amount__c = 0;
                                } else if(hadBSPAuthorisation(assessmentRecord)) {
                                    assessmentRecord.TSP_Levy_Amount__c = 0;
                                    assessmentRecord.BSP_Levy_Amount__c = 400;
                                }
                                
                            } else{
                                
                                if(isTrueUpdateStatus) {
                                    assessmentRecord = updateAssessmentAsHeld(assessmentRecord);
                                } 
                                
                                assessmentRecord.Total_Levy_Amount__c = assessmentRecord.Levy__c * totalTripCount;
                                assessmentRecord.BSP_Levy_Amount__c = assessmentRecord.BSP_Transaction_Count__c;
                                assessmentRecord.TSP_Levy_Amount__c = assessmentRecord.TSP_Transaction_Count__c;
                            }
                    } 
                    else if(assessmentRecord.Rebate_Approved__c == false && assessmentRecord.Exemption_Approved__c == false) {
                        
                        if(assessmentRecord.Annual_Estimates__c == annualEstimatesBetween151and400) {
                            
                            if(assessmentRecord.BSP_Transaction_Count__c == null && assessmentRecord.TSP_Transaction_Count__c == null) {
                                
                                if(isTrueUpdateStatus) {
                                    assessmentRecord = updateAssessmentAsAssessed(assessmentRecord, true);
                                } 
                                if(annualEstimateVsTripCounts.containsKey(assessmentRecord.Annual_Estimates__c)) {
                                    if(assessmentRecord.Taxpayer_Registration__r.Taxi_Service_Provider_Number__c != null &&
                                       assessmentRecord.Taxpayer_Registration__r.Booking_Service_Provider_Number__c != null ) {
                                           
                                           assessmentRecord.BSP_Transaction_Count__c = annualEstimateVsTripCounts.get(assessmentRecord.Annual_Estimates__c).BSP_Trip_Count__c;
                                           assessmentRecord.TSP_Transaction_Count__c = annualEstimateVsTripCounts.get(assessmentRecord.Annual_Estimates__c).TSP_Trip_Count__c;
                                           
                                       } else if(assessmentRecord.Taxpayer_Registration__r.Booking_Service_Provider_Number__c != null) {
                                           
                                           assessmentRecord.BSP_Transaction_Count__c = annualEstimateVsTripCounts.get(assessmentRecord.Annual_Estimates__c).BSP_TSP__c;
                                           
                                       } else if(assessmentRecord.Taxpayer_Registration__r.Taxi_Service_Provider_Number__c != null) {
                                           
                                           assessmentRecord.TSP_Transaction_Count__c = annualEstimateVsTripCounts.get(assessmentRecord.Annual_Estimates__c).BSP_TSP__c;
                                           
                                       }
                                }
                                /*
                                assessmentRecord.Total_Levy_Amount__c = 0;
                                assessmentRecord.BSP_Levy_Amount__c = 0;
                                assessmentRecord.TSP_Levy_Amount__c = 0;*/
                                
                                
                            } else if(totalTripCount >= 151 && totalTripCount <= 400) {
                                
                                if(isTrueUpdateStatus) {
                                    assessmentRecord = updateAssessmentAsAssessed(assessmentRecord, false);
                                }
                                
                                assessmentRecord.Total_Levy_Amount__c = assessmentRecord.Levy__c * totalTripCount;
                                assessmentRecord.BSP_Levy_Amount__c = assessmentRecord.BSP_Transaction_Count__c;
                                assessmentRecord.TSP_Levy_Amount__c = assessmentRecord.TSP_Transaction_Count__c;
                                
                            } else {
                                
                                if(isTrueUpdateStatus) {
                                    assessmentRecord = updateAssessmentAsAssessed(assessmentRecord, false);
                                } 
                                
                                assessmentRecord.Total_Levy_Amount__c = assessmentRecord.Levy__c * totalTripCount;
                                assessmentRecord.BSP_Levy_Amount__c = assessmentRecord.BSP_Transaction_Count__c;
                                assessmentRecord.TSP_Levy_Amount__c = assessmentRecord.TSP_Transaction_Count__c;
                            }
                        }
                        
                        else if(assessmentRecord.Annual_Estimates__c == annualEstimatesBetween401and600) {
                            
                            if(assessmentRecord.BSP_Transaction_Count__c == null && assessmentRecord.TSP_Transaction_Count__c == null) {
                                
                                if(isTrueUpdateStatus) {
                                    assessmentRecord = updateAssessmentAsAssessed(assessmentRecord, true);
                                } 
                                if(annualEstimateVsTripCounts.containsKey(assessmentRecord.Annual_Estimates__c)) {
                                    if(assessmentRecord.Taxpayer_Registration__r.Taxi_Service_Provider_Number__c != null &&
                                       assessmentRecord.Taxpayer_Registration__r.Booking_Service_Provider_Number__c != null ) {
                                           
                                           assessmentRecord.BSP_Transaction_Count__c = annualEstimateVsTripCounts.get(assessmentRecord.Annual_Estimates__c).BSP_Trip_Count__c;
                                           assessmentRecord.TSP_Transaction_Count__c = annualEstimateVsTripCounts.get(assessmentRecord.Annual_Estimates__c).TSP_Trip_Count__c;
                                           
                                       } else if(assessmentRecord.Taxpayer_Registration__r.Booking_Service_Provider_Number__c != null) {
                                           
                                           assessmentRecord.BSP_Transaction_Count__c = annualEstimateVsTripCounts.get(assessmentRecord.Annual_Estimates__c).BSP_TSP__c;
                                           
                                       } else if(assessmentRecord.Taxpayer_Registration__r.Taxi_Service_Provider_Number__c != null) {
                                           
                                           assessmentRecord.TSP_Transaction_Count__c = annualEstimateVsTripCounts.get(assessmentRecord.Annual_Estimates__c).BSP_TSP__c;
                                           
                                       }
                                }
                                /*
                                assessmentRecord.Total_Levy_Amount__c = 0;
                                assessmentRecord.BSP_Levy_Amount__c = 0;
                                assessmentRecord.TSP_Levy_Amount__c = 0;*/
                                
                                
                            } else if(totalTripCount >= 401 && totalTripCount <= 600) {
                                
                                if(isTrueUpdateStatus) {
                                    assessmentRecord = updateAssessmentAsAssessed(assessmentRecord, false);
                                }
                                
                                assessmentRecord.Total_Levy_Amount__c = assessmentRecord.Levy__c * totalTripCount;
                                assessmentRecord.BSP_Levy_Amount__c = assessmentRecord.BSP_Transaction_Count__c;
                                assessmentRecord.TSP_Levy_Amount__c = assessmentRecord.TSP_Transaction_Count__c;
                                
                            } else {
                                
                                if(isTrueUpdateStatus) {
                                    assessmentRecord = updateAssessmentAsAssessed(assessmentRecord, false);
                                }      
                                
                                assessmentRecord.Total_Levy_Amount__c = assessmentRecord.Levy__c * totalTripCount;
                                assessmentRecord.BSP_Levy_Amount__c = assessmentRecord.BSP_Transaction_Count__c;
                                assessmentRecord.TSP_Levy_Amount__c = assessmentRecord.TSP_Transaction_Count__c;
                            }
                        }
                        
                        else if(assessmentRecord.Annual_Estimates__c == annualEstimatesOver600) {
                            System.debug('estimate over 600');
                            Boolean isUpdatedBSPOrTSPCount = false;
                            
                            Map<String, Decimal> annualEstimateBandVsDefaultRetCount = new Map<String, Decimal>();
                            
                            for(Passenger_Service_Transaction_Bands__mdt record : passesngerServiceTransactionBandsMDT) {
                                annualEstimateBandVsDefaultRetCount.put(record.MasterLabel, record.Default_Estimate_if_NULL_Return__c);
                            }
                            
                            System.debug('**checking estimated bsp**');
                            if(assessmentRecord.Estimated_BSP_Transactions__c != null // If only to avoid null pointer, not criteria condition
                               && assessmentRecord.BSP_Transaction_Count__c == null
                               && hadBSPAuthorisation(assessmentRecord)) {
                                   System.debug('**setting BSP count**'+annualEstimateBandVsDefaultRetCount.get(assessmentRecord.Estimated_BSP_Transactions__c));
                                   isUpdatedBSPOrTSPCount = true;
                                   assessmentRecord.BSP_Transaction_Count__c = annualEstimateBandVsDefaultRetCount.get(assessmentRecord.Estimated_BSP_Transactions__c);
                               }
                            System.debug('**checking estimated tsp**');
                            if(assessmentRecord.Estimated_TSP_Transactions__c != null // If only to avoid null pointer, not criteria condition  
                               && assessmentRecord.TSP_Transaction_Count__c == null
                               && hadTSPAuthorisation(assessmentRecord)) {
                                   System.debug('**setting TSP count**');
                                   isUpdatedBSPOrTSPCount = true;
                                   assessmentRecord.TSP_Transaction_Count__c = annualEstimateBandVsDefaultRetCount.get(assessmentRecord.Estimated_TSP_Transactions__c);
                               }
                            
                            // Recalculate total trip count here based on new BSP and TSP Count
                            totalTripCount = 0;
                            if(assessmentRecord.BSP_Transaction_Count__c != null && assessmentRecord.TSP_Transaction_Count__c != null) {
                                totalTripCount = assessmentRecord.BSP_Transaction_Count__c + assessmentRecord.TSP_Transaction_Count__c;
                            } else if(assessmentRecord.BSP_Transaction_Count__c != null) {
                                totalTripCount = assessmentRecord.BSP_Transaction_Count__c;
                            } else if(assessmentRecord.TSP_Transaction_Count__c != null) {
                                totalTripCount = assessmentRecord.TSP_Transaction_Count__c;
                            }
                            
                            // If only to avoid null pointer, not criteria condition 
                            Decimal lowerHoldToleranceSelectedEstimateBandBSP;
                            Decimal upperHoldToleranceSelectedEstimateBandBSP;
                            Decimal lowerHoldToleranceSelectedEstimateBandTSP;
                            Decimal upperHoldToleranceSelectedEstimateBandTSP;
                            
                            if(assessmentRecord.Estimated_BSP_Transactions__c != null) {
                                lowerHoldToleranceSelectedEstimateBandBSP = annualEstimateBandVsLowerHoldTolerance.get(assessmentRecord.Estimated_BSP_Transactions__c);
                                upperHoldToleranceSelectedEstimateBandBSP = annualEstimateBandVsUpperHoldTolerance.get(assessmentRecord.Estimated_BSP_Transactions__c);
                            }
                            
                            if(assessmentRecord.Estimated_TSP_Transactions__c != null) {
                                lowerHoldToleranceSelectedEstimateBandTSP = annualEstimateBandVsLowerHoldTolerance.get(assessmentRecord.Estimated_TSP_Transactions__c);
                                upperHoldToleranceSelectedEstimateBandTSP = annualEstimateBandVsUpperHoldTolerance.get(assessmentRecord.Estimated_TSP_Transactions__c);
                            }
                            
                            // Check criteria condition
                            if((assessmentRecord.BSP_Transaction_Count__c != null
                                && assessmentRecord.BSP_Transaction_Count__c >= lowerHoldToleranceSelectedEstimateBandBSP
                                && assessmentRecord.BSP_Transaction_Count__c <= upperHoldToleranceSelectedEstimateBandBSP)
                               && (assessmentRecord.TSP_Transaction_Count__c != null
                                   && assessmentRecord.TSP_Transaction_Count__c >= lowerHoldToleranceSelectedEstimateBandTSP
                                   && assessmentRecord.TSP_Transaction_Count__c <= upperHoldToleranceSelectedEstimateBandTSP)) {
                                       
                                       if(isTrueUpdateStatus) {
                                           if(isUpdatedBSPOrTSPCount) {
                                               assessmentRecord = updateAssessmentAsAssessed(assessmentRecord, true);
                                           } else {
                                               assessmentRecord = updateAssessmentAsAssessed(assessmentRecord, false);
                                           }
                                       }
                                       
                                       assessmentRecord.Total_Levy_Amount__c = assessmentRecord.Levy__c * totalTripCount;  
                                       assessmentRecord.BSP_Levy_Amount__c = assessmentRecord.BSP_Transaction_Count__c;
                                       assessmentRecord.TSP_Levy_Amount__c = assessmentRecord.TSP_Transaction_Count__c;
                                   }
                            else if(assessmentRecord.TSP_Transaction_Count__c == null
                                    && assessmentRecord.BSP_Transaction_Count__c != null
                                    && assessmentRecord.BSP_Transaction_Count__c >= lowerHoldToleranceSelectedEstimateBandBSP
                                    && assessmentRecord.BSP_Transaction_Count__c <= upperHoldToleranceSelectedEstimateBandBSP) {
                                        
                                        if(isTrueUpdateStatus) {
                                            if(isUpdatedBSPOrTSPCount) {
                                                assessmentRecord = updateAssessmentAsAssessed(assessmentRecord, true);
                                            } else {
                                                assessmentRecord = updateAssessmentAsAssessed(assessmentRecord, false);
                                            }
                                        }  
                                        
                                        assessmentRecord.Total_Levy_Amount__c = assessmentRecord.Levy__c * totalTripCount;  
                                        assessmentRecord.BSP_Levy_Amount__c = assessmentRecord.BSP_Transaction_Count__c;
                                        assessmentRecord.TSP_Levy_Amount__c = assessmentRecord.TSP_Transaction_Count__c;
                                    }
                            else if(assessmentRecord.BSP_Transaction_Count__c == null
                                    && assessmentRecord.TSP_Transaction_Count__c != null
                                    && assessmentRecord.TSP_Transaction_Count__c >= lowerHoldToleranceSelectedEstimateBandTSP
                                    && assessmentRecord.TSP_Transaction_Count__c <= upperHoldToleranceSelectedEstimateBandTSP) {
                                        
                                        if(isTrueUpdateStatus) {
                                            if(isUpdatedBSPOrTSPCount) {
                                                assessmentRecord = updateAssessmentAsAssessed(assessmentRecord, true);
                                            } else {
                                                assessmentRecord = updateAssessmentAsAssessed(assessmentRecord, false);
                                            }
                                        }   
                                        
                                        assessmentRecord.Total_Levy_Amount__c = assessmentRecord.Levy__c * totalTripCount;  
                                        assessmentRecord.BSP_Levy_Amount__c = assessmentRecord.BSP_Transaction_Count__c;
                                        assessmentRecord.TSP_Levy_Amount__c = assessmentRecord.TSP_Transaction_Count__c;
                                    }
                            else {
                                
                                if(isTrueUpdateStatus) {
                                    assessmentRecord = updateAssessmentAsHeld(assessmentRecord);
                                }
                                
                                assessmentRecord.Total_Levy_Amount__c = assessmentRecord.Levy__c * totalTripCount;
                                assessmentRecord.BSP_Levy_Amount__c = assessmentRecord.BSP_Transaction_Count__c;
                                assessmentRecord.TSP_Levy_Amount__c = assessmentRecord.TSP_Transaction_Count__c;
                            }
                            
                            
                            if(tprVsAssessmentsMap.get(assessmentRecord.Taxpayer_Registration__c) != Null && tprVsAssessmentsMap.get(assessmentRecord.Taxpayer_Registration__c).size() == 3 
                               && assessmentRecord.Levy_Calculation_Method__c == GlobalConstants.LEVY_CALCULATION_METHOD_ESTIMATED_BY_SF) {
                                   
                                   Integer assessmentRecordSize = tprVsAssessmentsMap.get(assessmentRecord.Taxpayer_Registration__c).size();
                                   System.debug('assessmentRecordSize '+assessmentRecordSize);
                                   Decimal tspTotal = 0;
                                   Decimal bspTotal = 0;
                                   for(Assessment__c assessmentRec : tprVsAssessmentsMap.get(assessmentRecord.Taxpayer_Registration__c)) {
                                       if(assessmentRecord.TSP_Transaction_Count__c != null) {
                                           tspTotal += assessmentRec.TSP_Transaction_Count__c;
                                           isUpdatedBSPOrTSPCount = true;
                                           System.debug('tspTotal '+tspTotal);
                                           assessmentRecord.TSP_Transaction_Count__c = math.round(tspTotal/assessmentRecordSize);
                                       }
                                       if(assessmentRecord.BSP_Transaction_Count__c != null) {
                                           bspTotal += assessmentRec.BSP_Transaction_Count__c;
                                           isUpdatedBSPOrTSPCount = true;
                                           System.debug('bspTotal '+BspTotal);
                                           assessmentRecord.BSP_Transaction_Count__c = math.round(bspTotal/assessmentRecordSize);
                                       }
                                   }
                                   // Recalculate total trip count here based on new BSP and TSP Count for aggregated BSP and TSP
                                   totalTripCount = 0;
                                   if(assessmentRecord.BSP_Transaction_Count__c != null && assessmentRecord.TSP_Transaction_Count__c != null) {
                                       totalTripCount = assessmentRecord.BSP_Transaction_Count__c + assessmentRecord.TSP_Transaction_Count__c;
                                   } else if(assessmentRecord.BSP_Transaction_Count__c != null) {
                                       totalTripCount = assessmentRecord.BSP_Transaction_Count__c;
                                   } else if(assessmentRecord.TSP_Transaction_Count__c != null) {
                                       totalTripCount = assessmentRecord.TSP_Transaction_Count__c;
                                   }
                                   
                                   if(isTrueUpdateStatus) {
                                       if(isUpdatedBSPOrTSPCount) {
                                           assessmentRecord = updateAssessmentAsAssessed(assessmentRecord, true);
                                           assessmentRecord.Is_Average_Calculation_Used__c = true;
                                       } 
                                   }
                                   
                                   assessmentRecord.Total_Levy_Amount__c = assessmentRecord.Levy__c * totalTripCount;  
                                   assessmentRecord.BSP_Levy_Amount__c = assessmentRecord.BSP_Transaction_Count__c;
                                   assessmentRecord.TSP_Levy_Amount__c = assessmentRecord.TSP_Transaction_Count__c;
                                   
                               }
                        } 
                        
                    } // End of scenarions
                    
                } // End of If - Mannual Assessment No 
                
            } // End of for
            
            if(listAssessments.size() > 0) {
                if(isTrueUpdateStatus) {
                    Database.SaveResult[] results = Database.update(listAssessments, false);
                    for (Database.SaveResult sr : results) {
                        if(!sr.isSuccess()) {
                            system.debug('json error: ' + JSON.serialize(sr.getErrors()));
                        }
                    }
                }
            }
            
        } catch(Exception ex) {
            System.debug('AssessmentLevyAmountCalculator::calculate' + ex.getLineNumber());
            System.debug('AssessmentLevyAmountCalculator::calculate' + ex.getMessage());
        }
    }
    
    @TestVisible
    private static Assessment__c updateAssessmentAsHeld(Assessment__c assessmentRecord) {
        
        assessmentRecord.Status__c = GlobalConstants.ASSESSMENT_STATUS_HELD;
        
        assessmentRecord.Manual_Assessment_Required__c = 'Yes';
        if(String.isBlank(assessmentRecord.Manual_Assessment_Comments__c)) {
            assessmentRecord.Manual_Assessment_Comments__c = System.Label.Manual_Assessment_Required_Comment;
        }
        
        assessmentRecord.Levy_Calculation_Method__c = GlobalConstants.LEVY_CALCULATION_METHOD_ASSESSED_MANUALLY;
        
        return assessmentRecord;
    }
    
    private static Assessment__c updateAssessmentAsAssessed(Assessment__c assessmentRecord, Boolean isEstimatedBySF) {
        
        assessmentRecord.Status__c = GlobalConstants.ASSESSMENT_STATUS_ASSESSED;
        System.debug('annual estimate: '+assessmentRecord.Annual_Estimates__c+' IsEstimatedBySF: '+isEstimatedBySF);
        if(isEstimatedBySF) {
            assessmentRecord.Levy_Calculation_Method__c = GlobalConstants.LEVY_CALCULATION_METHOD_ESTIMATED_BY_SF;
        } else {
            assessmentRecord.Levy_Calculation_Method__c = GlobalConstants.LEVY_CALCULATION_METHOD_ASSESSED_BY_SF;
        }
        
        return assessmentRecord;
    }
    
    //function to validate if service provider had an active/suspended TSP authorisation during the
    //assessment period
    @AuraEnabled
    public static Boolean hadTSPAuthorisation(Assessment__c tempAssessment) {        
        return tprVsTspAuth.get(tempAssessment.Taxpayer_Registration__c);
    }
    
    //function to validate if service provider had an active/suspended BSP authorisation during the
    //assessment period
    @AuraEnabled
    public static Boolean hadBSPAuthorisation(Assessment__c tempAssessment) {         
        return tprVsBspAuth.get(tempAssessment.Taxpayer_Registration__c);
    }
    
    //method to fetch last three previous assessments which are assessed by salesforce
    private static Map<String, List<Assessment__c>> previousAssessments(List<Assessment__c> listAssessments) {
        
        Map<String, List<Assessment__c>> tprVsAssessmentsMap = new Map<String, List<Assessment__c>>();
        Set<Id>taxPayerRegId = new Set<Id>();
        
        for(Assessment__c assmnt : listAssessments){
            taxPayerRegId.add(assmnt.Taxpayer_Registration__c);
        }
        
        List<Assessment__c> previousThreeRec = [SELECT id, Taxpayer_Registration__c, BSP_Transaction_Count__c, TSP_Transaction_Count__c 
                                                FROM Assessment__c 
                                                WHERE Taxpayer_Registration__c IN: taxPayerRegId 
                                                AND (Assessment_Type__c =: GlobalConstants.ASSESSMENT_TYPE_ASSESSMENT OR Assessment_Type__c =: GlobalConstants.ASSESSMENT_TYPE_ASSESSMENT_COMPROMISED)
                                                AND Taxpayer_Registration__r.Rebate_Approved__c = false
                                                AND Levy_Calculation_Method__c =: GlobalConstants.LEVY_CALCULATION_METHOD_ASSESSED_BY_SF
                                                AND Period_End_Date__c <: System.today().addMonths(-1).toStartOfMonth().addDays(-1)
                                                AND Period_End_Date__c >: System.today().addMonths(-7)
                                                ORDER BY Period_End_Date__c DESC]; 
        System.debug('previousThreeRec '+previousThreeRec);
        
        if(previousThreeRec!=null && !previousThreeRec.isEmpty()) {
            
            for(Assessment__c a : previousThreeRec){
                if(tprVsAssessmentsMap.containsKey(a.Taxpayer_Registration__c) && tprVsAssessmentsMap.get(a.Taxpayer_Registration__c).size() <= 2) {
                    tprVsAssessmentsMap.get(a.Taxpayer_Registration__c).add(a);
                }
                else if(!tprVsAssessmentsMap.containsKey(a.Taxpayer_Registration__c)){
                    tprVsAssessmentsMap.put(a.Taxpayer_Registration__c, new List<Assessment__c>{a});
                }
            }  
        }
        System.debug('tprVsAssessmentsMap '+tprVsAssessmentsMap);
        return tprVsAssessmentsMap;
    }
    
    private static void checkForAuths(List<Assessment__c> assessments){
        Set<String> activeAuthStatuses = new Set<String>();
        activeAuthStatuses.add(GlobalConstants.GRANTED_UNCONDITIONALLY);
        activeAuthStatuses.add(GlobalConstants.GRANTED_CONDITIONALLY);
        activeAuthStatuses.add(GlobalConstants.AUTHORISATION_SUSPENDED);
        Set<Id> tprIds = new Set<Id>();
        
        for(Assessment__c assessment : assessments){
            tprIds.add(assessment.Taxpayer_Registration__c);
        }
        
        
        Map<Id, Tax_Payer_Registration__c> relatedTPRs = new Map<Id, Tax_Payer_Registration__c> ([SELECT Booking_Service_Provider_Number__c, Booking_Service_Provider_Number__r.Start_Date__c, 
                                                                                                  Booking_Service_Provider_Number__r.End_Date__c, 
                                                                                                  Taxi_Service_Provider_Number__c, Taxi_Service_Provider_Number__r.Start_Date__c, Taxi_Service_Provider_Number__r.End_Date__c
                                                                                                  FROM Tax_Payer_Registration__c 
                                                                                                  WHERE Id IN :tprIds
                                                                                                  AND Status__c = :GlobalConstants.STATUS_ACTIVE
                                                                                                  AND Booking_Service_Provider_Number__c != NULL
                                                                                                  AND Booking_Service_Provider_Number__r.Status__c IN :activeAuthStatuses]);
        
        tprVsBspAuth = new Map<Id, Boolean>();      
        
        for(Assessment__c assessment : assessments){
            tprVsBspAuth.put(assessment.Taxpayer_Registration__c, false);
            if(relatedTPRs.containsKey(assessment.Taxpayer_Registration__c)){
                Tax_Payer_Registration__c tpr = relatedTPRs.get(assessment.Taxpayer_Registration__c);
                if(assessment.Period_Start_Date__c >= tpr.Booking_Service_Provider_Number__r.Start_Date__c
                   || assessment.Period_End_Date__c <= tpr.Booking_Service_Provider_Number__r.End_Date__c)
                    tprVsBspAuth.put(assessment.Taxpayer_Registration__c, true);
            }
        }
        
        relatedTPRs = new Map<Id, Tax_Payer_Registration__c> ([SELECT Booking_Service_Provider_Number__c, Booking_Service_Provider_Number__r.Start_Date__c, Booking_Service_Provider_Number__r.End_Date__c, 
                                                               Taxi_Service_Provider_Number__c, Taxi_Service_Provider_Number__r.Start_Date__c, Taxi_Service_Provider_Number__r.End_Date__c
                                                               FROM Tax_Payer_Registration__c 
                                                               WHERE Id IN :tprIds
                                                               AND Status__c = :GlobalConstants.STATUS_ACTIVE
                                                               AND Taxi_Service_Provider_Number__c != NULL
                                                               AND Taxi_Service_Provider_Number__r.Status__c IN :activeAuthStatuses]);
        tprVsTspAuth = new Map<Id, Boolean>();
        for(Assessment__c assessment : assessments){
            tprVsTspAuth.put(assessment.Taxpayer_Registration__c, false);
            if(relatedTPRs.containsKey(assessment.Taxpayer_Registration__c)){
                Tax_Payer_Registration__c tpr = relatedTPRs.get(assessment.Taxpayer_Registration__c);
                if(assessment.Period_Start_Date__c >= tpr.Taxi_Service_Provider_Number__r.Start_Date__c
                   || assessment.Period_End_Date__c <= tpr.Taxi_Service_Provider_Number__r.End_Date__c)
                    tprVsTspAuth.put(assessment.Taxpayer_Registration__c, true);
            }
        }
        
    }
}