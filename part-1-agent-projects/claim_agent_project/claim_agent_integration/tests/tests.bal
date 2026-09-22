import ballerina/ai;
import ballerina/ai.eval;
import ballerina/test;

isolated function loadEvalsetData() returns map<[ai:ConversationThread]>|error {
    return ai:loadConversationThreads("tests/resources/evalsets/session-7559810d.evalset.json");
}

@test:Config {
    groups: ["evaluations"],
    minPassRate: 0.9,
    dataProvider: loadEvalsetData
}
function evaluateAiAgentToolTrajectory(ai:ConversationThread thread) returns error? {
    check eval:evaluateToolTrajectory(targetAgent = aiAgent, thread = thread, matchMode = eval:SUBSET);
}
