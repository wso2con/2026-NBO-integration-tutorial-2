import ballerinax/googleapis.sheets;

final McpToolKit aiMcpbasetoolkit = check new ("http://localhost:9091/mcp", {
    version: "1.0.0",
    name: "mcp-server"
});

final sheets:Client sheetsClient = check new ({
    auth: {
        clientId: sheetsClientId,
        clientSecret: sheetsClientSecret,
        refreshUrl: sheetsRefreshUrl,
        refreshToken: sheetsRefreshToken
    }
});
