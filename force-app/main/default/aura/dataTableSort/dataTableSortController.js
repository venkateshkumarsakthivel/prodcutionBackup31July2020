({
    initialize: function(component, event, helper)  {
        console.log("data sorting component initialize");
    },
    
    sort: function(component, event, helper)  {
        var _column = $(event.target).closest("th")[0];
        var _sortd = helper.sortd(_column);

        var _entities = component.get("v.entities");        

        if(undefined == _column.dataset.custom)  {
            _entities = _.sortBy(_entities, _column.dataset.field);
        } else {
            _entities = _.sortBy(_entities, function(_entity) { return _entity[_column.dataset.custom][_column.dataset.field] });   
        }
        
        if(_sortd == "desc") _entities = _entities.reverse();
        component.set("v.entities", _entities);
    }
})