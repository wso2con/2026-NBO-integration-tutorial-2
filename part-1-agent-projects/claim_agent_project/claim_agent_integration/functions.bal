import ballerina/ai;
import ballerina/time;
import ballerinax/googleapis.sheets;

# Appends a row to the 'agent-log' sheet recording the interaction.
# + question - the customer's question
# + answer - the agent's answer
# + return - an error if the append operation fails
@ai:AgentTool
@display {label: "", iconPath: "https://bcentral-packageicons.azureedge.net/images/ballerinax_googleapis.sheets_4.0.0.png"}
isolated function logInteraction(string question, string answer) returns error? {
    string timestamp = time:utcToString(time:utcNow());
    sheets:A1Range a1Range = {sheetName: "agent-log"};
    sheets:ValueRange|error result = sheetsClient->appendValue(spreadsheetId, [timestamp, question, answer], a1Range);
    if result is error {
        return result;
    }
}
