package com.example.dns.ledger;

public class Peer {

    private String ip;
    private String port;

    public Peer(String ip, String port) {
        this.ip = ip;
        this.port = port;
    }

    public String getIp() {
        return ip;
    }

    public String getPort() {
        return port;
    }
}
