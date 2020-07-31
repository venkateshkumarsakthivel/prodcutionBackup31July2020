({
    clean: function(_field)  {
        return undefined == _field ? '' : _field;
    },
    
    sortd: function(_column)  {
        if(false == $(_column).hasClass("slds-column-sort-asc") && false == $(_column).hasClass("slds-column-sort-desc"))  {
            $(_column).addClass("slds-column-sort-desc");
        }
        
        $(_column).closest("table").find("th").each(function(_index)  {
            if (_index != $(_column).index())
                $(this).removeClass("slds-column-sort-desc slds-column-sort-asc");
        });
        
        $(_column).toggleClass("slds-column-sort-asc slds-column-sort-desc");
        
        return ($(_column).hasClass("slds-column-sort-asc")) ? "asc" : "desc";
    }
})