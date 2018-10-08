const StorageChaincode = require('chaincode-node-storage');
const MortgageParser = require('rosreestr-mortgage-parser').MortgageParser;
const collections = require('./collections.json');
const access = require('./access.json');
const _ = require('lodash');

//----------------------------------------------------------------------------------------
// ERROR CODES:
//----------------------------------------------------------------------------------------
const PARSING_ERROR = 1;
const RESPONSE_ERROR = 2;

const NO_REQUEST_TYPE = 3;
const UNSUPPORTED_REQUEST_TYPE = 4;
const NO_REGISTRATION_NUMBER = 5;
const NO_MORTGAGE_WITH_NUMBER = 6;
const MORTGAGE_ALREADY_EXIST = 7;

const CONSISTENCY_ERROR_NO_DEPONENT = 11;
const CONSISTENCY_ERROR_NO_DEPOSITORY = 12;
const CONSISTENCY_ERROR_NO_ACCOUNT = 13;
const CONSISTENCY_ERROR_NO_ACC_SEC = 14;
//----------------------------------------------------------------------------------------

module.exports = class ReferenceChaincode extends StorageChaincode {

    async Init(stub) {
        let result = await super.Init(stub);
        // Prepopulate some data
        // Account types
        await this.put(['accountType', 'A10', '{"name":"Счёт документарных ценных бумаг"}']);
        await this.put(['accountType', 'A24', '{"name":"Счёт ценных бумаг депонентов"}']);
        await this.put(['accountType', 'L10', '{"name":"Владелец"}']);
        await this.put(['accountType', 'L34', '{"name":"Номинальный держатель"}']);
        // Section types
        await this.put(['sectionType', '001', '{"name":"Основной"}']);
        await this.put(['sectionType', '002', '{"name":"Базовый"}']);
        await this.put(['sectionType', '003', '{"name":"Принято в оплату паев ПИФ"}']);
        await this.put(['sectionType', '004', '{"name":"Блокированы до списания"}']);
        await this.put(['sectionType', '005', '{"name":"Блокированы до выпуска"}']);
        await this.put(['sectionType', '006', '{"name":"Блокированы до внесения изменений"}']);
        await this.put(['sectionType', '007', '{"name":"Блокированы под арестом"}']);
        await this.put(['sectionType', '008', '{"name":"Блокированы"}']);
        await this.put(['sectionType', '009', '{"name":"Блокированы в залоге"}']);
        await this.put(['sectionType', '010', '{"name":"Блокированы в залоге под арестом"}']);
        await this.put(['sectionType', '011', '{"name":"Блокированы в РИП"}']);
        // depository table prepopulation
        await this.put(['depository', '1027700132195', '{"ogrn":"1027700132195","name":"Сбербанк","fullName":"ПАО Сбербанк","inn":"7707083893","kpp":"773601001","code":"SBER","activeFrom":"01/01/2018"}']);
        await this.put(['depository', '1027739609391', '{"ogrn":"1027739609391","name":"Банк ВТБ","fullName":"Банк ВТБ (ПАО)","inn":"7707083893","kpp":"773601001","code":"VTB","activeFrom":"01/01/2018"}']);
        await this.put(['depository', '1021600000124', '{"ogrn":"1021600000124","name":"АК БАРС БАНК","fullName":"АО ИК «АК БАРС БАНК»","inn":"1653001805","kpp":"165601001","code":"AKBARS","activeFrom":"01/01/2018"}']);
        await this.put(['depository', '1027700167110', '{"ogrn":"1027700167110","name":"Банк ГПБ","fullName":"Банк ГПБ (АО)","inn":"7744001497","kpp":"997950001","code":"GPB","activeFrom":"01/01/2018"}']);
        await this.put(['depository', '1177700002150', '{"ogrn":"1177700002150","name":"АФТ","fullName":"Ассоциация ФинТех","inn":"9705086966","kpp":"770501001","code":"AFT","activeFrom":"01/01/2018"}']);
        await this.put(['depository', '1027739326449', '{"ogrn":"1027739326449","name":"Райффайзенбанк","fullName":"АО «Райффайзенбанк»","inn":"7744000302","kpp":"770201001","code":"RAIF","activeFrom":"01/01/2018"}']);
        await this.put(['depository', '1107746400827', '{"ogrn":"1107746400827","name":"Спецдеп Сбербанк","fullName":"ООО «Спецдепозитарий Сбербанка»","inn":"7736618039","kpp":"772501001","code":"SBERSD","activeFrom":"01/01/2018"}']);
        // deponent table prepopulation
        await this.put(['deponent', '1107746400827', '{"activeFrom":"1107746400827","actualAddress":"1107746400827","canceledFrom":"1107746400827","code":"1107746400827","economicsSectorCode":"S11","egrulIssuanceDate":"1107746400827","email":"1107746400827","fullName":"1107746400827","inn":"1107746400827","kpp":"1107746400827","name":"1107746400827","ogrn":"1107746400827","ogrnInstitution":"1107746400827","phoneNumber":"1107746400827","postAddress":"1107746400827","region":"01"}']);

        // await this.privatePut( ["account","10.3214125","{\"aType\":\"A10\",\"number\":\"10.3214125\",\"comment\":\"comment 1\",\"createdAt\":\"07/10/2018\",\"status\":\"OPEN\",\"closedAt\":\"--\",\"updatedAt\":\"07/10/2018\"}"]  )
        // await this.privatePut( ["account","34.1233214","{\"aType\":\"L34\",\"number\":\"34.1233214\",\"activeCounterpartyAccount\":\"1233214\",\"comment\":\"comment 2\",\"createdAt\":\"07/10/2018\",\"status\":\"OPEN\",\"closedAt\":\"--\",\"updatedAt\":\"07/10/2018\"}"] )

        // await this.put(['account','210520501','{"aType":"L34","number":"210520501","activeCounterparty":"1021600000124","activeCounterpartyAccount":"123","passiveCounterparty":"1027700132195","comment":"ком","createdAt":"30/08/2018","status":"OPEN","closedAt":"--","updatedAt":"30/08/2018"}']);
        // await this.put(['account','200722601','{"aType":"A10","number":"200722601","comment":"","createdAt":"30/08/2018","status":"OPEN","closedAt":"--","updatedAt":"30/08/2018"}']);
        // await this.put(['account','10.3214125','{"aType":"L10","number":"10.3214125","activeCounterparty":"1021600000124","comment":"","createdAt":"30/08/2018","status":"OPEN","closedAt":"--","updatedAt":"30/08/2018"}']);
        // await this.put(['account','34.1233214','{"aType":"L34","number":"34.1233214","activeCounterparty":"1027739326449","activeCounterpartyAccount":"34.1233214","passiveCounterparty":"1027700132195","comment":"","createdAt":"30/08/2018","status":"OPEN","closedAt":"--","updatedAt":"30/08/2018"}']);

        return result;
    }

    async put(args) {

        if (args.length < 2) {
            throw new Error('invalid number of arguments: supply either ["storage", id] to record the org that stores ' +
                'entity with id or [objectType, id, value] to record an entity');
        }
        else if (args.length === 2) {
            if (args[0] !== 'storage') {
                throw new Error('invalid arguments: supply ["storage", id] to record the org that stores entity with id');
            }

            args.push(this.creator.org);
        }

        await super.put(args);
    }

    async delete(args) {
        this.logger.debug('delete args=%j', args);
        await super.delete(args);
    }

    //======================================================================
    // Transfer related stuff
    //======================================================================

    async transferSecurity(args) {
        if (args.length !== 2) {
            throw new Error('invalid number of arguments: supply Storage and ID');
        }
        let id = args[0];
        let storage = args[1];
        let key = this.toKey(this.stub, ['security', id]);
        let transferCollection = this.findTransferCollectionName(this.creator.org, storage);


        let security = await this.doGet(['security', id]);
        await this.stub.putPrivateData(transferCollection, key, security);
        await this.doDelete(['security', id]);
        await this.addSecurityAuditRecord('TX', {id, to: storage});
        this.setEvent('TransferSecurity', [{org: storage, from: this.creator.org, source: transferCollection, id}]);
    }

    async putSecurityFromTransfer(args) {
        this.logger.debug('putSecurityFromTransfer %j', args);
        let collectionName = args[0];
        let id = args[1];
        let from = args[2];
        let key = this.toKey(this.stub, ['security', id]);

        let security = await this.stub.getPrivateData(collectionName, key);
        await this.stub.putPrivateData(this.pCollectionName(), key, security);
        await this.addSecurityAuditRecord('RX', {id, from});
        await this.stub.deletePrivateData(collectionName, key);
        await this.put(['storage', id]); // record that now we owning the asset
    }

    findTransferCollectionName(org1, org2) {
        let pc = collections.find(e => e.name === `${org1}${org2}` || e.name === `${org2}${org1}`);
        if (pc) return pc.name;
        throw new Error(`Can not find transfer collection for [${org1}, ${org2}]`);
    }

    //======================================================================
    // Private Store stuff
    //======================================================================

    async privatePut(args) {
        if (args.length === 1) {
            await this.putZip(args);
        } else if (args.length === 3) {
            await this.putEntity(args);
        } else {
            throw new Error('invalid number of arguments: supply' +
                ' either [json] with value.data of base64 encoded zip' +
                ' or [id, transferChannel] to save security from transfer' +
                ' or [id, objectType, json] to save arbitrary entity');
        }
    }

    async privateGet(args) {
        return await this.doGet(args);
    }

    async privateList(args) {
        return await this.doList(args);
    }

    async privateDelete(args) {
        let table = args[0];
        let id = args[1];
        if ('security' !== table) {
            await this.addInternalAuditRecord('DELETE', {table, id});
        }
        await this.doDelete(args);
        await this.delete(['storage', args[1]]);
    }

    async putZip(args) {
        this.logger.debug('putZip %j', args);

        const zipEntry = JSON.parse(args[0]);
        const parser = new MortgageParser();
        const parseResult = parser.parseZip(zipEntry.data, '1');
        this.logger.debug('ParseResult %j', parseResult);
        let validationStatus = {status: "", reason: ""};

        if (parseResult.errors && parseResult.errors.length) {
            await this.addSecurityAuditRecord('FAIL', {
                entry: zipEntry,
                error: {code: PARSING_ERROR, msg: parseResult.errors.toString()}
            });
            return;
        }


        if (parseResult.payload === undefined) {
            await this.addSecurityAuditRecord('FAIL', {
                entry: zipEntry,
                error: {code: PARSING_ERROR, msg: 'No payload in parsing result'}
            });
            return;
        }

        if (parseResult.payload.errors && parseResult.payload.errors.length) {
            await this.addSecurityAuditRecord('FAIL', {
                entry: zipEntry,
                error: {code: PARSING_ERROR, msg: parseResult.payload.errors.toString()}
            });
            return;
        }


        if (parseResult.request.requestType) { // full zip
            let entityInfo = '';
            let id = _.get(parseResult, 'payload.regNumber', false);

            //ref to ternary operation
            if (id) {
                const previous = await this.doGet(['security', id]);
            } else {
                const previous = '';
            }

            let responseForMG = '';

            switch (parseResult.request.requestType) {

                case 'transferElectronicMortgageDepositary':
                    entityInfo = await this.validateConsistency(parseResult.payload);

                    if (entityInfo.error) {
                        await this.addSecurityAuditRecord('FAIL', {entry: zipEntry, error: entityInfo.error});
                        validationStatus.status = false;
                    }
                    else {
                        await this.addSecurityAuditRecord('VALIDATED', {entry: zipEntry});
                        validationStatus.status = true;

                    }

                    responseForMG = this.responseGenerator(parseResult, validationStatus);

                    zipEntry.response = responseForMG.response.value;

                    this.logger.debug(parseResult.request.requestType, "\n", zipEntry.response);

                    let newEntry = {...entityInfo, documents: [zipEntry]};

                    //TODO Check response on web-client

                    return;

                case 'noticeReleaseMortgage':
                    entityInfo = await this.validateConsistency(parseResult.payload);

                    if (parseResult.payload.regNumber === undefined) {
                        await this.addSecurityAuditRecord('FAIL', {
                            entry: zipEntry,
                            error: {code: NO_REGISTRATION_NUMBER}
                        });
                        //validationStatus.status=false;
                        return;
                    }

                    if (entityInfo.error) {
                        await this.addSecurityAuditRecord('FAIL', {entry: zipEntry, error: entityInfo.error});
                        //validationStatus.status=false;
                        return;
                    }


                    if (previous === '') {

                        responseForMG = this.responseGenerator(parseResult, validationStatus);

                        if (responseForMG.errors && responseForMG.errors.length) {
                            await this.addSecurityAuditRecord('FAIL', {
                                entry: zipEntry,
                                error: {code: RESPONSE_ERROR, msg: responseForMG.errors.toString()}
                            });
                            return;
                        }
                        zipEntry.response = responseForMG.response.value;
                        let newEntry = {...entityInfo, documents: [zipEntry]};
                        await this.addSecurityAuditRecord('UPLOAD', {id, entry: zipEntry});
                        await this.putEntity(['security', id, JSON.stringify(newEntry)]);
                        await this.put(['storage', id]); // record that now we owning the asset
                    } else {
                        await this.addSecurityAuditRecord('FAIL', {
                            entry: zipEntry,
                            error: {code: MORTGAGE_ALREADY_EXIST, id}
                        });
                    }
                    return;

                case 'directionAgreement':
                    if (parseResult.payload.regNumber === undefined) {
                        await this.addSecurityAuditRecord('FAIL', {
                            entry: zipEntry,
                            error: {code: NO_REGISTRATION_NUMBER}
                        });
                        return;
                    }

                    if (previous === '') {
                        await this.addSecurityAuditRecord('FAIL', {
                            entry: zipEntry,
                            error: {code: NO_MORTGAGE_WITH_NUMBER, id}
                        });
                        validationStatus.status = false;
                        let responseForMG = this.responseGenerator(parseResult, validationStatus);

                    } else {

                        let responseForMG = this.responseGenerator(parseResult, validationStatus);

                        if (responseForMG.errors && responseForMG.errors.length) {
                            await this.addSecurityAuditRecord('FAIL', {
                                entry: zipEntry,
                                error: {code: RESPONSE_ERROR, msg: responseForMG.errors.toString()}
                            });
                            let existingEntry = JSON.parse(previous);
                            zipEntry.response = responseForMG.response.value;
                            existingEntry.documents = [...existingEntry.documents, zipEntry];
                            await this.addSecurityAuditRecord('UPDATE', {id, entry: zipEntry});
                            await this.putEntity(['security', id, JSON.stringify(existingEntry)]);
                            await this.put(['storage', id]); // record that now we owning the asset
                        }

                    }
                    return;

                case 'noticeRedemption':
                    if (parseResult.payload.regNumber === undefined) {
                        await this.addSecurityAuditRecord('FAIL', {
                            entry: zipEntry,
                            error: {code: NO_REGISTRATION_NUMBER}
                        });
                        return;
                    }

                    let responseForMG = this.responseGenerator(parseResult, validationStatus);

                    if (previous === '') {
                        await this.addSecurityAuditRecord('FAIL', {
                            entry: zipEntry,
                            error: {code: NO_MORTGAGE_WITH_NUMBER, id}
                        });
                        validationStatus.status = false;
                    } else {
                        let responseForMG = this.responseGenerator(parseResult, validationStatus);
                        zipEntry.response = responseForMG.response.value;
                        await this.addSecurityAuditRecord('DELETE', {entry: zipEntry, id});
                        await this.privateDelete(['security', id]);
                        validationStatus.status = true;

                    }
                    return;

                case 'checkingInformationOwner':
                    //TODO Check owners from request
                    if (parseResult.payload.regNumber === undefined) {
                        await this.addSecurityAuditRecord('FAIL', {
                            entry: zipEntry,
                            error: {code: NO_REGISTRATION_NUMBER}
                        });
                        return;
                    }

                    responseForMG = this.responseGenerator(parseResult, validationStatus);

                    if (previous === '') {
                        await this.addSecurityAuditRecord('FAIL', {
                            entry: zipEntry,
                            error: {code: NO_MORTGAGE_WITH_NUMBER, id}
                        });
                        validationStatus.status = false;
                    } else {
                        responseForMG = this.responseGenerator(parseResult, validationStatus);
                        zipEntry.response = responseForMG.response.value;
                        await this.addSecurityAuditRecord('DELETE', {entry: zipEntry, id});
                        await this.privateDelete(['security', id]);
                        validationStatus.status = true;

                    }
                    return;

                default:
                    await this.addSecurityAuditRecord('FAIL', {
                        entry: zipEntry,
                        error: {code: UNSUPPORTED_REQUEST_TYPE, typeName: parseResult.request.requestType}
                    });
            }

        } else { // short version
            await this.addSecurityAuditRecord('FAIL', {entry: zipEntry, error: {code: NO_REQUEST_TYPE}});
        }

    }

    async responseGenerator(parseResult, validationStatus) {
        this.logger.debug('Generating response for mortgage...');
        let txDate = this.formatDate(new Date(parseInt(this.getMillis(this.stub.getTxTimestamp()).toString())));
        this.logger.debug('TX date is: %s', txDate);

        let changes = {};
        switch (validationStatus.status) {
            case true:
                changes = {
                    'comment': 'Принят',
                    'status': 'true'
                };
                break;
            case false:
                changes = {
                    'comment': 'Не принят',
                    'status': 'false'
                };
                //TODO Add reason;
                break;
        }

        if (validationStatus.status) {

            switch (parseResult.request.requestType) {
                case 'transferElectronicMortgageDepositary'|'noticeReleaseMortgage'|'noticeRedemption':
                    changes = changes.concat({'dateDepository': txDate});
                    break;

                case 'checkingInformationOwner':
                    changes = changes.concat(
                        {
                            //TODO Get correct values from mortgage
                            'email': 'ewew@wwew.ru',
                            'surname': 'wew',
                            'firstname': 'wewe',
                            'birthDate': '2018-05-28',
                            'birthPlace': 'adww',
                            'documentTypeCode': '008001001000',
                            'passport_number': '234232',
                            'passport_series': '223424',
                            'firstOwnerKind': '359000000100',
                            'dateDepository': txDate

                        });
                    break;

                case 'directionAgreement':
                    changes = changes.concat(
                        {'dateReceiptAgreement':txDate}
                    );
                    break;
            }
        }

        let baseResponsePattern = {
            'cadastralNumber': [parseResult.payload.cadastralNumber.cadastralNumber],
            'mortgageNumber': parseResult.payload.regNumber
        };

        let responseData = baseResponsePattern.concat(changes);
        let responseForMG = parser.generateResponse(parseResult.request.requestType, responseData.concat(changes));
        this.logger.debug('Generated: %j', responseForMG);
        return responseForMG;
    }


    // returns entityInfo
    // deponent field - deponent information contains: { ogrn, account, section }
    // depository field - depository information contains: { ogrn, account, section }
    // errors field - the list of validation errors (if any)
    async validateConsistency(mortgage) {
        this.logger.debug('Validating mortgage...');

        let deponentAccountNumber = mortgage.deponentAccount.number.toString().trim();
        let deponentAccountSection = mortgage.deponentAccount.section.toString().trim();
        let deponentValidationResult = await this.validateAccountAndSection(deponentAccountNumber, deponentAccountSection);
        if (deponentValidationResult) {
            this.logger.debug('Mortgage validation failed - Deponent information inconsistent: %j', deponentValidationResult);
            return {error: deponentValidationResult};
        }

        let depositoryAccountNumber = mortgage.depositoryAccount.number.toString().trim();
        let depositoryAccountSection = mortgage.depositoryAccount.section.toString().trim();
        let depositoryValidationResult = await this.validateAccountAndSection(depositoryAccountNumber, depositoryAccountSection);
        if (depositoryValidationResult) {
            this.logger.debug('Mortgage validation failed - Depository information inconsistent: %j', depositoryValidationResult);
            return {error: depositoryValidationResult};
        }

        let storageOgrn = mortgage.storageOgrn;
        this.logger.debug('Trying to find deponent with OGRN [%s]...', storageOgrn);
        let storageDepositoryResponse = await this.get(['deponent', storageOgrn]);
        this.logger.debug('Got result %j', storageDepositoryResponse);
        if (storageDepositoryResponse == '') {
            return {error: {code: CONSISTENCY_ERROR_NO_DEPONENT, ogrn: storageOgrn}};
        }

        let recordOgrn = mortgage.recordOgrn;
        this.logger.debug('Trying to find depository with OGRN [%s]...', recordOgrn);
        let recordDepositoryResponse = await this.get(['depository', recordOgrn]);
        this.logger.debug('Got result %j', recordDepositoryResponse);
        if (recordDepositoryResponse == '') {
            return {error: {code: CONSISTENCY_ERROR_NO_DEPOSITORY, ogrn: recordOgrn}};
        }

        this.logger.debug('Mortgage validation result: ALL FINE');
        return {
            deponent: {
                ogrn: storageOgrn,
                account: deponentAccountNumber,
                section: deponentAccountSection
            },
            depository: {
                ogrn: recordOgrn,
                account: depositoryAccountNumber,
                section: depositoryAccountSection
            }
        };
    }

    async validateAccountAndSection(account, section) {
        this.logger.debug('Trying to find account [%s]...', account);
        let res = await this.doGet(['account', account]);
        this.logger.debug('Got result: %j', res);
        if (res == '') {
            return {code: CONSISTENCY_ERROR_NO_ACCOUNT, account};
        }
        let accountData = JSON.parse(res);
        this.logger.debug('Account data: %j', accountData);
        this.logger.debug('Trying to find section %s', section);
        let sectionData = accountData.sections && accountData.sections.find(s => {
            return s.id === section;
        });
        this.logger.debug('Got result: %j', sectionData);
        if (sectionData) {
            return undefined;
        }
        return {code: CONSISTENCY_ERROR_NO_ACC_SEC, account, section};
    }

    async putEntity(args) {
        this.logger.debug('putEntity %j', args);
        let table = args[0];
        let key = args[1];
        // Add audit record only for internal events, as for securities audit should already be done.
        if ('security' !== table) {
            if (await this.isNewRecord(table, key)) {
                await this.addInternalAuditRecord('NEW', {table, key});
            } else {
                await this.addInternalAuditRecord('UPDATE', {table, key});
            }
        }
        await this.doPut(args);
    }

    getEventToMeInvokeOnTransfer(transferChannel, fcn, args) {
        return {org: this.creator.org, channel: transferChannel, chaincode: 'transfer', fcn: fcn, args: args};
    }

    async addInternalAuditRecord(operation, description) {
        let txTimestamp = this.getMillis(this.stub.getTxTimestamp());
        this.logger.debug(`Internal audit record timestamp: ${txTimestamp}`);
        let auditRecord = {
            timestamp: txTimestamp.toString(),
            operation, description
        };
        await this.doPut(['internalOperations', auditRecord.timestamp, JSON.stringify(auditRecord)]);
    }

    async addSecurityAuditRecord(operation, description) {
        let txTimestamp = this.getMillis(this.stub.getTxTimestamp());
        this.logger.debug(`Internal audit record timestamp: ${txTimestamp}`);
        let auditRecord = {
            timestamp: txTimestamp.toString(),
            operation, description
        };
        await this.doPut(['securityOperations', auditRecord.timestamp, JSON.stringify(auditRecord)]);
    }

    async isNewRecord(table, key) {
        let previous = await this.doGet([table, key]);
        return '' == previous;
    }

    getMillis(timestamp) {
        return (timestamp.seconds.low + ((timestamp.nanos / 1000000) / 1000)) * 1000;
    }

    formatDate(date) {
        return date.toISOString().split('T')[0];
    }

    async doPut(args) {
        let req = this.toKeyValue(this.stub, args);
        let client = this.creator.org;
        let objectType = args[0];
        this.logger.debug('put key=%s, objectType=%s, client=%s', req.key, objectType, client);
        let defaultStore = access[client][objectType].store;
        if (defaultStore) {
            await this.stub.putPrivateData(defaultStore, req.key, Buffer.from(req.value));
            let views = access[client][objectType].views;
            this.logger.debug("Additional Views: " + JSON.stringify(views));
            if (views) {
                var v;
                for (v in views) {
                    let view = views[v].name;
                    let viewFunction = views[v].view;
                    this.logger.debug("Additional Put to View: " + view);
                    if (view && viewFunction && this[viewFunction]) {
                        viewFunction = this[viewFunction];
                        let boundViewFunction = viewFunction.bind(this);
                        let viewValue = JSON.stringify(await boundViewFunction(JSON.parse(req.value)));
                        await this.stub.putPrivateData(view, req.key, Buffer.from(viewValue));
                        this.logger.debug('Stored: view=%s, key=%s, value=%s', view, req.key, viewValue);
                    }
                }
            }
        } else {
            throw new Error(`No meta information for ${this.creator.org} and ${objectType}`);
        }
    }

    async doGet(args) {
        let objectType = args[0];
        let id = args[1];
        let view = args.length === 3 ? args[2] : undefined;
        let key = this.stub.createCompositeKey(objectType, [id]);
        let client = this.creator.org;
        this.logger.debug('get key=%s, objectType=%s, client=%s', key, objectType, client);
        if (view) {
            return await this.stub.getPrivateData(view, key);
        } else {
            let defaultStore = access[client][objectType].store;
            if (defaultStore) {
                return await this.stub.getPrivateData(defaultStore, key);
            } else {
                throw new Error(`No meta information for ${this.creator.org} and ${objectType}`);
            }
        }
    }

    async doDelete(args) {
        let key = this.toKey(this.stub, args);
        let client = this.creator.org;
        let objectType = args[0];
        this.logger.debug('delete key=%s, objectType=%s, client=%s', key, objectType, client);
        let defaultStore = access[client][objectType].store;
        if (defaultStore) {
            await this.stub.deletePrivateData(defaultStore, key);
        } else {
            throw new Error(`No meta information for ${this.creator.org} and ${objectType}`);
        }
    }

    async doList(args) {
        if (args.length < 1) {
            throw new Error('incorrect number of arguments, objectType is required');
        }
        let objectType = args[0];
        let attributes = args.slice(1);
        let client = this.creator.org;
        this.logger.debug('list args=%j objectType=%j, attributes=%j, client=%s', args, objectType, attributes, client);
        let defaultStore = access[client][objectType].store;
        if (defaultStore) {
            let iter = await this.stub.getPrivateDataByPartialCompositeKey(defaultStore, objectType, attributes);
            let result = await this.toQueryResult(iter);
            this.logger.debug('================================ RESULT =====================================');
            this.logger.debug(JSON.stringify(result));
            this.logger.debug('=============================================================================');
            return result;
        } else {
            this.logger.debug("Looking for Views...");
            let views = access[client][objectType].readViews;
            this.logger.debug("Views: " + JSON.stringify(views));
            if (views) {
                let result = [];
                //
                var v;
                for (v in views) {
                    let view = views[v];
                    this.logger.debug("Fetching View: " + view);
                    let iter = await this.stub.getPrivateDataByPartialCompositeKey(view, objectType, attributes);
                    let res = await iter.next();
                    do {
                        if (res.value && res.value.value.toString()) {
                            let jsonRes = {};
                            jsonRes.key = res.value.key;
                            jsonRes.view = view;
                            try {
                                jsonRes.value = JSON.parse(res.value.value.toString('utf8'));
                            } catch (err) {
                                jsonRes.value = res.value.value.toString('utf8');
                            }
                            result.push(jsonRes);
                        }
                    } while (!res.done);
                    iter.close();
                }
                //
                this.logger.debug('================================ RESULT =====================================');
                this.logger.debug(JSON.stringify(result));
                this.logger.debug('=============================================================================');
                return Buffer.from(JSON.stringify(result));
            }
        }
        throw new Error(`No meta information for ${this.creator.org} and ${objectType}`);
    }

    //
    // Views functions
    //

    async securityViewForRegulator(value) {
        return {
            deponent: {
                ogrn: value.deponent.ogrn,
                account: value.deponent.account,
                section: value.deponent.section
            },
            depository: {
                ogrn: value.depository.ogrn,
                account: value.depository.account,
                section: value.depository.section
            }
        };
    }

};
