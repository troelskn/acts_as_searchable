ActAsSearchable
===

Adds a class method `act_as_searchable` on ActiveRecord models. To use, call the method in your models:

    class Ticket < ActiveRecord::Base
      act_as_searchable
    end

This will provide a scope `search` on the model, that takes a string for searching full-text.

TODO: Document the query format

TODO: Document runtime options

The method takes options to customise the search, but will default to search all string-like columns on the model.

TODO: Document the options

License
---

This project is available under the terms of MIT-LICENSE.