global class P2PWIBSFileListScheduler implements Schedulable, Database.AllowsCallouts  {

    global void execute(SchedulableContext schedulableContext)  {
        Id P2PWIBSResponseFileFacadeJobId = Database.executeBatch(new P2PWIBSResponseFileFacade());
        if(!Test.isRunningTest()) {	FlexQueue.moveJobToFront(P2PWIBSResponseFileFacadeJobId);}
    }
}