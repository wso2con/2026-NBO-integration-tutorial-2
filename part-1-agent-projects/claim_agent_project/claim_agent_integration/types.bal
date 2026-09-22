type AgentQueryRequest record {|
    string question;
    string sessionId?;
|};

type AgentQueryResponse record {|
    string sessionId;
    string answer;
|};
