import ballerina/io;
import ballerina/http;
import ballerina/websub;
import ballerina/runtime;
import ballerinax/java.jdbc;
import mosip/repository;
import ballerina/config;

public function main() {

    jdbc:Client jdbcClient = new ({url : config:getAsString("mosip.hub.datasource-url","jdbc:postgresql://localhost:9001/hub"),
        username : config:getAsString("mosip.hub.datasource-username"), password : config:getAsString("mosip.hub.datasource-password"),   dbOptions: {useSSL: false}}
        );

    websub:HubPersistenceStore hubpimpl = new repository:HubPersistenceImpl(jdbcClient);
    io:println("Starting up the Ballerina Hub Service");

    websub:Hub webSubHub;
    var result = websub:startHub(new http:Listener(config:getAsInt("mosip.hub.port")), "/websub", "/hub",
        hubConfiguration = {
        remotePublish: {
            enabled: true
        },
        hubPersistenceStore:hubpimpl
    }
    );
    if (result is websub:Hub) {
        webSubHub = result;
    } else if (result is websub:HubStartedUpError) {
        webSubHub = result.startedUpHub;
    } else {
        io:println("Hub start error:" + <string>result.detail()?.message);
        return;
    }
    while(true){
    runtime:sleep(1);  
    }
}