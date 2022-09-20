package com.example.dns.ledger;

import com.owlike.genson.annotation.JsonProperty;
import org.hyperledger.fabric.contract.annotation.DataType;

import java.util.Map;
import java.util.Objects;


@DataType()
public class Org implements LedgerMapObject {
    private final String orgId;
    String domain;
    String orgIp;
    String peerPort;
    String peer0Port;
    String wwwPort;
    String peerName;
    String wwwIp;
    Map<String, Peer> peers;

    public Org(String orgId, String domain, String orgIp, String peerPort, String wwwPort, String peerName, String wwwIp, Map<String, Peer> peers) {
        this.orgId = orgId;
        this.domain = domain;
        this.orgIp = orgIp;
        this.peerPort = peerPort;
        this.wwwPort = wwwPort;
        this.peerName = peerName;
        this.wwwIp = wwwIp;
        this.peers = peers;
    }

    public Org(@JsonProperty("orgId") final String orgId) {
        this.orgId = orgId;
    }

    public Org(@JsonProperty("orgId") String orgId, @JsonProperty("domain") String domain,
               @JsonProperty("orgIp") String orgIp, @JsonProperty("peerPort") String peerPort) {
        this.orgId = orgId;
        this.domain = domain;
        this.orgIp = orgIp;
        this.peerPort = peerPort;
    }

    public Org(@JsonProperty("orgId") String orgId, @JsonProperty("domain") String domain,
               @JsonProperty("orgIp") String orgIp, @JsonProperty("peerPort") String peerPort,
               @JsonProperty("peerName") String peerName, @JsonProperty("wwwPort") String wwwPort) {
        this.orgId = orgId;
        this.domain = domain;
        this.orgIp = orgIp;
        this.peerPort = peerPort;
        this.peerName = peerName;
        this.wwwPort = wwwPort;
    }

    @Override
    public String objectNameInMap() {
        return orgId + "." + domain;
    }

    public String getOrgId() {
        return orgId;
    }

    public String getDomain() {
        return domain;
    }

    public String getOrgIp() {
        return orgIp;
    }

    public String getPeerPort() {
        return peerPort != null ? peerPort : peer0Port;
    }

    public String getWwwPort() {
        return wwwPort;
    }

    public String getPeerName() {
        return peerName;
    }

    public String getWwwIp() {
        return wwwIp;
    }


    public Map<String, Peer> getPeers() {
        return peers;
    }

    @Override
    public boolean equals(final Object obj) {
        if (this == obj) {
            return true;
        }

        if ((obj == null) || (getClass() != obj.getClass())) {
            return false;
        }

        Org other = (Org) obj;

        return Objects.deepEquals(new String[]{getOrgId(), getDomain()},
                new String[]{other.getOrgId(), other.getDomain()});
    }

    @Override
    public int hashCode() {
        return Objects.hash(getOrgId(), getDomain());
    }

    @Override
    public String toString() {
        return this.getClass().getSimpleName() + "@" + Integer.toHexString(hashCode()) + " [name=" + orgId + ", domain="
                + domain + ", orgIp=" + orgIp + ", peerName=" + peerName + ", peerPort=" + peerPort + ", wwwIp=" + wwwIp + ", wwwPort=" + wwwPort + "]";
    }

}
