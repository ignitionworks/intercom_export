Intercom Export
===============

System to help export Intercom.io conversations into Zendesk tickets. The codebase is designed to be adaptable
for importing into other systems or even exporting from things other than Intercom.

Usage
-----

```
$ intercom_export --intercom-app-id <APP ID> --intercom-api-key <APP KEY> \
                  --zendesk-address <DOMAIN>.zendesk.com --zendesk-username <USERNAME> --zendesk-token <TOKEN>
```

Design
------

The `coordinator` is the heart of the import. This breaks the problem down into several discrete stages.

 1. Source - This is simple an enumerable, currently this is an enumerable of all Intercom conversations
 2. Splitter - This takes an item from the source and splits it into several `parts` that make syncying
    easier. For instance an Intecom conversation will be split into all of the users involved in the
    conversation, and the conversation itself with the users replaced by references.
 3. Finder - This takes a part (something in the land of Intercom), and tries to find it's equivalent in
    Zendesk
 4. Differ - This compares the Intercom part, with the search result from Zendesk and then creates commands.
 5. Executor - This executes each command.

The idea of breaking it into these components is to allow other front-ends (Intercom), to be slotted in by
only adding a few classes. It should also be possible to slot in other back-ends (Zendesk) with a small amount
of modification.

Tests
-----

$ rspec

Status
------

This has worked for us importing around 5000 tickets from Intercom to Zendesk. Performance is slow due to the
number of queries required.
