/**
 *  Description: OrderItem trigger handler class
 */
public with sharing class OrderItemTriggerHandler {
 
    //before insert handler
    public static void beforeInsert(List<OrderItem> newOrderItems) {
        //Commented on Jul 25 2019 for BAU monthly release(Auth fee) to not to calculate previous year auth fee as per the guidielines defined in p2p documentation.
        //AuthorisationFeeRecalculator authFeeCalculation = new AuthorisationFeeRecalculator();
       // authFeeCalculation.checkWithPreviousYearAuthorisationFee(newOrderItems);
    }
    
  //after insert handler
  public static void afterInsert(Map<Id, OrderItem> newOrderItems) {
    
    OrderUpdator performOrderUpdator = new OrderUpdator(newOrderItems);
    performOrderUpdator.performOrderUpdate();
  }
  
  //after update handler
  public static void afterUpdate(Map<Id, OrderItem> newOrderItems) {
  
    OrderUpdator performOrderUpdator = new OrderUpdator(newOrderItems);
    performOrderUpdator.performOrderUpdate();
  }
  
  //before update handler
  public static void beforeUpdate(Map<Id, OrderItem> newOrderItems, Map<Id, OrderItem> oldOrderItems) {
  
      AuthorisationFeeRecalculator authFeeCalculation = new AuthorisationFeeRecalculator();
      authFeeCalculation.calculateAuthorisationFee(newOrderItems, oldOrderItems);
  }
}