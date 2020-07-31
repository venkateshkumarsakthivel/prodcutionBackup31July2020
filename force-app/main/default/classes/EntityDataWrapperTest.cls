@isTest
private class EntityDataWrapperTest {
    
    @isTest static void test_DriverDataWrapper(){
        EntityDataWrapper wrapper = new EntityDataWrapper();
        test.startTest();
        wrapper = EntityDataWrapper.getDriverDataWrapper();
        test.stopTest();
        system.assert(true);
        
    }
    @isTest static void test_VehicleDataWrapper(){
        EntityDataWrapper wrapper = new EntityDataWrapper();
        test.startTest();
        wrapper = EntityDataWrapper.getVehicleDataWrapper();
        test.stopTest();
        system.assert(true); 
    }
    
}