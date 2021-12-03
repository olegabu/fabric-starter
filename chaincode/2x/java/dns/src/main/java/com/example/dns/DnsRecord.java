package com.example.dns;

import java.util.Objects;


public class DnsRecord {
    String ip;
    String record;

    public DnsRecord(String ip, String record) {
        this.ip = ip;
        this.record = record;
    }

    public String getIp() {
        return ip;
    }

    public String getRecord() {
        return record;
    }

    @Override
    public boolean equals(final Object obj) {
        if (this == obj) {
            return true;
        }

        if ((obj == null) || (getClass() != obj.getClass())) {
            return false;
        }

        DnsRecord other = (DnsRecord) obj;

        return Objects.deepEquals(new String[]{getIp(), getRecord()},
                new String[]{other.getIp(), other.getRecord()});
    }

    @Override
    public int hashCode() {
        return Objects.hash(getIp(), getRecord());
    }

    @Override
    public String toString() {
        return this.getClass().getSimpleName() + "@" + Integer.toHexString(hashCode()) + " [ip=" + ip + ", record=" + record + "]";
    }

}
