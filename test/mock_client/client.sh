# list
grpcurl  --plaintext 127.0.0.1:18223 list
grpcurl -import-path ../../logic -proto logic.proto list

# describe
grpcurl  --plaintext 127.0.0.1:18223 describe
grpcurl  --plaintext 127.0.0.1:18223 describe logic.LogicDealer

# create account
grpcurl --plaintext -d '{"nickname": "zhangsan","broker": "dev1:18080"}'\
 127.0.0.1:18223 proto.LogicDealer/CreateAccount

grpcurl --plaintext -d '{"nickname": "lisi","broker": "dev1:18080"}'\
 127.0.0.1:18223 proto.LogicDealer/CreateAccount

# match
grpcurl --plaintext -d '{"accountId":10}'\
 127.0.0.1:18223 proto.LogicDealer/Match

# ViewedAck
grpcurl --plaintext -d '{"sessionId":110000,"accountId":100,"msgId":20000}'\
 127.0.0.1:18223 proto.LogicDealer/ViewedAck
