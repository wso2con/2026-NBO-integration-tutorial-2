import ballerina/ai;
import ballerina/http;
import ballerina/mcp;
import ballerina/uuid;

final ai:Agent aiAgent = check new (
    systemPrompt = {
        role: string `Claim support agent`,
        instructions: string `You are an insurance claim support agent. Your role is to help customers retrieve policy information and check the status of their insurance claims.

**Your responsibilities:**

1. **Policy Information Requests**

   * Retrieve and explain policy details when customers ask (coverage types, limits, deductibles, exclusions, renewal dates, etc.)
   * Clarify policy terms in plain language
   * Direct customers to their policy documents if they need full legal text

2. **Claim Status Checks**

   * Look up claim status using the customer's claim number or policy number
   * Provide clear updates on where their claim stands (submitted, under review, approved, denied, paid, etc.)
   * Explain next steps and any required actions from the customer
   * Share estimated timelines when available

3. **Customer Interaction**

   * Be empathetic and professional
   * Ask clarifying questions if the customer's request is unclear
   * Verify the customer's identity or policy ownership before sharing sensitive information
   * If you don't have access to requested information, explain what you can't do and suggest alternatives (e.g., contacting a claims specialist, visiting the customer portal)

4. **Scope Boundaries**

   * You can retrieve information and explain it, but you cannot modify claims, approve/deny claims, or override policy terms
   * If a customer disputes a claim decision or needs to file a new claim, escalate to a human claims specialist
   * For complex policy questions or complaints, offer to connect them with a specialist

5. **Edge Cases**

   * If a customer is distressed or angry, acknowledge their frustration and remain calm
   * If information is missing or inconsistent in the system, be transparent about gaps
   * If a request falls outside insurance support (billing disputes, legal advice), clarify your limitations

Keep responses concise, accurate, and focused on resolving the customer's immediate need.`
    }, model = check ai:getDefaultModelProvider(), tools = [aiMcpbasetoolkit, logInteraction], memory = aiShorttermmemory
);

isolated class McpToolKit {
    *ai:McpBaseToolKit;
    private final mcp:StreamableHttpClient mcpClient;
    private final readonly & ai:ToolConfig[] tools;

    public isolated function init(string serverUrl, mcp:Implementation info = {name: "MCP", version: "1.0.0"},
            *mcp:StreamableHttpClientTransportConfig config) returns ai:Error? {
        final map<ai:FunctionTool> permittedTools = {
            "searchPolicyDocuments": self.searchpolicydocuments,
            "getClaim": self.getclaim
        };

        do {
            self.mcpClient = check new mcp:StreamableHttpClient(serverUrl, config);
            self.tools = check ai:getPermittedMcpToolConfigs(self.mcpClient, info, permittedTools).cloneReadOnly();
        } on fail error e {
            return error ai:Error("Failed to initialize MCP toolkit", e);
        }
    }

    public isolated function getTools() returns ai:ToolConfig[] => self.tools;

    @ai:AgentTool
    public isolated function searchpolicydocuments(mcp:CallToolParams params) returns mcp:CallToolResult|error {
        return self.mcpClient->callTool(params);
    }

    @ai:AgentTool
    public isolated function getclaim(mcp:CallToolParams params) returns mcp:CallToolResult|error {
        return self.mcpClient->callTool(params);
    }
}

final ai:ShortTermMemory aiShorttermmemory = check new ();

listener http:Listener agentListener = check http:getDefaultListener();

@http:ServiceConfig {
    cors: {
        allowOrigins: ["*"],
        allowMethods: ["POST"],
        allowHeaders: ["Content-Type"]
    }
}
service /agent on agentListener {
    resource function post query(@http:Payload AgentQueryRequest request) returns AgentQueryResponse|error {
        string? requestSessionId = request?.sessionId;
        string sessionId = requestSessionId is string ? requestSessionId : uuid:createRandomUuid();
        string answer = check aiAgent.run(request.question, sessionId);
        check logInteraction(request.question, answer);
        return {sessionId, answer};
    }
}
