package com.example.dns.ledger;

import com.owlike.genson.annotation.JsonProperty;
import org.hyperledger.fabric.contract.annotation.DataType;

import java.util.Objects;


@DataType()
public class Orderer implements LedgerMapObject {
    private final String ordererName;
    String domain;
    String ordererIp;
    String ordererPort;
    String wwwPort;
    String wwwIp;

    public Orderer(String ordererName, String domain, String ordererIp, String ordererPort, String wwwPort, String wwwIp) {
        this.ordererName = ordererName;
        this.domain = domain;
        this.ordererIp = ordererIp;
        this.ordererPort = ordererPort;
        this.wwwPort = wwwPort;
        this.wwwIp = wwwIp;
    }

    public Orderer(@JsonProperty("ordererName") final String ordererName) {
        this.ordererName = ordererName;
    }

    public Orderer(@JsonProperty("ordererName") String ordererName, @JsonProperty("domain") String domain,
                   @JsonProperty("ordererIp") String ordererIp, @JsonProperty("ordererPort") String ordererPort) {
        this.ordererName = ordererName;
        this.domain = domain;
        this.ordererIp = ordererIp;
        this.ordererPort = ordererPort;
    }

    public Orderer(@JsonProperty("ordererName") String ordererName, @JsonProperty("domain") String domain,
                   @JsonProperty("ordererIp") String ordererIp, @JsonProperty("ordererPort") String ordererPort,
                   @JsonProperty("wwwPort") String wwwPort) {
        this.ordererName = ordererName;
        this.domain = domain;
        this.ordererIp = ordererIp;
        this.ordererPort = ordererPort;
        this.wwwPort = wwwPort;
    }

    @Override
    public String getMapKey() {
        return ordererName + "." + domain;
    }

    public String getOrdererName() {
        return ordererName;
    }

    public String getDomain() {
        return domain;
    }

    public String getOrdererIp() {
        return ordererIp;
    }

    public String getOrdererPort() {
        return ordererPort;
    }

    public String getWwwPort() {
        return wwwPort;
    }

    public String getWwwIp() {
        return wwwIp;
    }

    @Override
    public boolean equals(final Object obj) {
        if (this == obj) {
            return true;
        }

        if ((obj == null) || (getClass() != obj.getClass())) {
            return false;
        }

        Orderer other = (Orderer) obj;

        return Objects.deepEquals(new String[]{getOrdererName(), getDomain()},
                new String[]{other.getOrdererName(), other.getDomain()});
    }

    @Override
    public int hashCode() {
        return Objects.hash(getOrdererName(), getDomain());
    }

    @Override
    public String toString() {
        return this.getClass().getSimpleName() + "@" + Integer.toHexString(hashCode()) + " [name=" + ordererName + ", domain="
                + domain + ", ip=" + ordererIp + ", wwwIp=" + wwwIp + ", wwwPort=" + wwwPort + "]";
    }

}
