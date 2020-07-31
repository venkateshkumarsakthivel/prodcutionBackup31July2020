/*
 * Helper class to trigger update of parent order record inorder to 
 * trigger recalculation of Bpay reference number
 */
public with sharing class OrderUpdator {

   private Map<Id, OrderItem> newOrderItems;
    
    
   public OrderUpdator(Map<Id, OrderItem> newOrderItems){
    
        this.newOrderItems = newOrderItems;
   }
   
   /*
    * Method to perform collect parent order ids and perform a dry update
    */
   public void performOrderUpdate() {
     
     Map<Id, Order> orderRecordsToUpdate = new Map<Id, Order>();
     
     for(OrderItem tempOrderItem : newOrderItems.values()) {
      
       Order tempOrder = new Order();
       tempOrder.Id = tempOrderItem.OrderId;
       
       orderRecordsToUpdate.put(tempOrder.Id, tempOrder);
     }
     
     if(orderRecordsToUpdate.size() > 0)
       update orderRecordsToUpdate.values();
   }
}