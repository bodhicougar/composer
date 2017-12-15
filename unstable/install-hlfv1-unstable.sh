ME=`basename "$0"`
if [ "${ME}" = "install-hlfv1-unstable.sh" ]; then
  echo "Please re-run as >   cat install-hlfv1-unstable.sh | bash"
  exit 1
fi
(cat > composer.sh; chmod +x composer.sh; exec bash composer.sh)
#!/bin/bash
set -e

# Docker stop function
function stop()
{
P1=$(docker ps -q)
if [ "${P1}" != "" ]; then
  echo "Killing all running containers"  &2> /dev/null
  docker kill ${P1}
fi

P2=$(docker ps -aq)
if [ "${P2}" != "" ]; then
  echo "Removing all containers"  &2> /dev/null
  docker rm ${P2} -f
fi
}

if [ "$1" == "stop" ]; then
 echo "Stopping all Docker containers" >&2
 stop
 exit 0
fi

# Get the current directory.
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Get the full path to this script.
SOURCE="${DIR}/composer.sh"

# Create a work directory for extracting files into.
WORKDIR="$(pwd)/composer-data-unstable"
rm -rf "${WORKDIR}" && mkdir -p "${WORKDIR}"
cd "${WORKDIR}"

# Find the PAYLOAD: marker in this script.
PAYLOAD_LINE=$(grep -a -n '^PAYLOAD:$' "${SOURCE}" | cut -d ':' -f 1)
echo PAYLOAD_LINE=${PAYLOAD_LINE}

# Find and extract the payload in this script.
PAYLOAD_START=$((PAYLOAD_LINE + 1))
echo PAYLOAD_START=${PAYLOAD_START}
tail -n +${PAYLOAD_START} "${SOURCE}" | tar -xzf -

# stop all the docker containers
stop



# run the fabric-dev-scripts to get a running fabric
export FABRIC_VERSION=hlfv11
./fabric-dev-servers/downloadFabric.sh
./fabric-dev-servers/startFabric.sh

# pull and tage the correct image for the installer
docker pull hyperledger/composer-playground:unstable
docker tag hyperledger/composer-playground:unstable hyperledger/composer-playground:latest

# Start all composer
docker-compose -p composer -f docker-compose-playground.yml up -d

# manually create the card store
docker exec composer mkdir /home/composer/.composer

# build the card store locally first
rm -fr /tmp/onelinecard
mkdir /tmp/onelinecard
mkdir /tmp/onelinecard/cards
mkdir /tmp/onelinecard/client-data
mkdir /tmp/onelinecard/cards/PeerAdmin@hlfv1
mkdir /tmp/onelinecard/client-data/PeerAdmin@hlfv1
mkdir /tmp/onelinecard/cards/PeerAdmin@hlfv1/credentials

# copy the various material into the local card store
cd fabric-dev-servers/fabric-scripts/hlfv1/composer
cp creds/* /tmp/onelinecard/client-data/PeerAdmin@hlfv1
cp crypto-config/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp/signcerts/Admin@org1.example.com-cert.pem /tmp/onelinecard/cards/PeerAdmin@hlfv1/credentials/certificate
cp crypto-config/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp/keystore/114aab0e76bf0c78308f89efc4b8c9423e31568da0c340ca187a9b17aa9a4457_sk /tmp/onelinecard/cards/PeerAdmin@hlfv1/credentials/privateKey
echo '{"version":1,"userName":"PeerAdmin","roles":["PeerAdmin", "ChannelAdmin"]}' > /tmp/onelinecard/cards/PeerAdmin@hlfv1/metadata.json
echo '{
    "type": "hlfv1",
    "name": "hlfv1",
    "orderers": [
       { "url" : "grpc://orderer.example.com:7050" }
    ],
    "ca": { "url": "http://ca.org1.example.com:7054",
            "name": "ca.org1.example.com"
    },
    "peers": [
        {
            "requestURL": "grpc://peer0.org1.example.com:7051",
            "eventURL": "grpc://peer0.org1.example.com:7053"
        }
    ],
    "channel": "composerchannel",
    "mspID": "Org1MSP",
    "timeout": 300
}' > /tmp/onelinecard/cards/PeerAdmin@hlfv1/connection.json

# transfer the local card store into the container
cd /tmp/onelinecard
tar -cv * | docker exec -i composer tar x -C /home/composer/.composer
rm -fr /tmp/onelinecard

cd "${WORKDIR}"

# Wait for playground to start
sleep 5

# Kill and remove any running Docker containers.
##docker-compose -p composer kill
##docker-compose -p composer down --remove-orphans

# Kill any other Docker containers.
##docker ps -aq | xargs docker rm -f

# Open the playground in a web browser.
case "$(uname)" in
"Darwin") open http://localhost:8080
          ;;
"Linux")  if [ -n "$BROWSER" ] ; then
	       	        $BROWSER http://localhost:8080
	        elif    which xdg-open > /dev/null ; then
	                xdg-open http://localhost:8080
          elif  	which gnome-open > /dev/null ; then
	                gnome-open http://localhost:8080
          #elif other types blah blah
	        else
    	            echo "Could not detect web browser to use - please launch Composer Playground URL using your chosen browser ie: <browser executable name> http://localhost:8080 or set your BROWSER variable to the browser launcher in your PATH"
	        fi
          ;;
*)        echo "Playground not launched - this OS is currently not supported "
          ;;
esac

echo
echo "--------------------------------------------------------------------------------------"
echo "Hyperledger Fabric and Hyperledger Composer installed, and Composer Playground launched"
echo "Please use 'composer.sh' to re-start, and 'composer.sh stop' to shutdown all the Fabric and Composer docker images"

# Exit; this is required as the payload immediately follows.
exit 0
PAYLOAD:
� ��3Z �=KlIv���Ճ$Nf�1�@��36?����h�&ْh�IQ�eǫivɖ�������^�%�I	0� � �9�l� 2��r�%A�yU�$�eɶ,g`0f���{�^�_}�G5�lG�k��X�<hۦg��AW�|JJ:�$����Ғ����	�OfH5��i!�|�ω�s�縲��;�-j��p��C�!��4r�p��lj
vr���v��_�+k����s�Vڨu�6�u�u����T��Z��:%Btm9�ϑ�qv{�}@[Uܒ=�e���bې�a�I�|X�M��XZr�֔��#d�Ab�N��x&�:������	>	��:wNf����g�?��J�N�h��O�<�	��?�'RBB���g����_DY�8�ԌXSv:�cz��Qx�:RT��j6���4/n��mmn�ң��gat#��^EVO��؞n�*�A_8n�X���nѰ�H3`BtE"��[Z�t��x� �	R}�r�����b�V͞!�z�f���N�H�2����O% ���������s��(jy��BR�܎��Q6Td�y��#�3�h��B�ur\Ӻ~�{�qU~e�JUY�<��i-��o���x����m�Ҁ�+�7��M��q:a��
��(l��t�����b�Z&��A���d�C�g!kwE�"-B����H�fPj4Kv��#�1*��i��I���8��<�5�q�a�`մ頙�Ǝ�3��E�`2h}��#�+P)�99xs���cJ�LCP���3�'!�-�]�J��p�>���y�K;�Un�`��Vb%\ձ�`�`+.�u4��L�N�g(̱Gg�:UNtQa�/u�J��ÄX��#�ȴ�݁�w�`+*Br������	ܠ�t����۷ǀS�G�L4��w���k�_�Y�T��������hM�8-��a*��$��<�_D9���M�h^^�̰��\��S�O&t�'.$ө�@�����/��<���nZ]l�,;s[�\Ԃ�oF�G�1��aI��-7Y���6A N��p/��X/m�m�jc�spM���'vuapm�i ��5�͕#G�䮊�z���#շJ����g���y' �� �p�{rt���uȇ�O6��d���ߌu��0������&`�,T���덽F�,mn7N�zl�|
]w0L���86���+|�����6^���G�H��ͥk��=z��f^�Z�1z��V$4�<���@&.#��6�F�]nӬ�/��)���/��&���F;��Z HxR� �_�~;��o��,*���i�z��<��|}���x�T���%�g��/�<��Ρ�qe�"��!!�G�Q�g�*fF�7�c"�b�F��$�
 �|4N��:<1;.�<�l ��-[;�]k{�V��5^��)u6a(ڰ½Ū<['5׵�\,-�U�nl�!�k��%���3JH�܎iӁ0��`�隂�� ̦�#B4Κ�gڪm�K�C.���(Y3�5��{t��0�b�=�x�MO�Ոl+�;t��n�H���4�(��� ;
�]�6Tl(�$���l�rCj#�#�5�Ѥ?�a̯ߒ�j���B�s�����*������?��Q������<�7��<�	�O�2���_D����]fؿbcȹ�ۢ�Ռd���f���#�L���'���b�����r���U�$K�W� �ٿ��L�?���_L9���*��me�!��Lu"��*�l�@��Z��E��(����ocx���X��N�����0u/~�;�b~��"���O���WQ����?��L�O������_D9����[��?X>Oퟏ�IrN$�����B���_�Úji��"lۦ}Y�f����nW6T'ʑ#��mGn��7�Sn��ن��%��S��ET���ѹ��c�6�U�ܰ"��o��ǴY���`d�܄l��l�4	uM�.�宥�`k��E?㸪l;xO����q�:$�y��Q���89�WMna�]���}΅��H��u�y\X��UK���r�Ek73�pdd�b��uQ��+o��~�����Z.�@/pg-��F���@޶���]�
1Bt����b���*=_"O��9�^X_�ܣ�`���k��1bwj�'r]�,lH����=iet�?<ԋ��ﶂ��K��e��M{�PI,��$���)c��69Gy�.��"*pO�N��3<\0͠zg���:��ݜ�!}�Gv{�n��Ͻ
�.ۄ������1�B���*ϐلp7b�5b�Z��=+�Q�'�#2(����YG6�s�5v��
�`a��v��bf�䈗V��%���A`��� h.O�QD�L:�3î2uZl������Q�O��kj�I,����N�����f]ګJ��ja��ZZ�����cLt++#��tEtg��I0���Hsz�Qz(���_�a�]a��&��D����3�4֛�oi9s��
��O����?�"h*I�Ia�����W���<���b9B�哄ET��7�\�Mѓ(7��$r{��4��t���瘣a:�G�h���z���i���z)�8|��~{)���t��̮oZ�協3��Q^��4θ�C���A ��x<9�������?̂���_z��_>�NL��%S���ǅXb�������e�˶�H��Q'u�c�j�[$��Z|��n�FJ*�t��A0B�� �E"n�������AE���4�`���2}o�bp��Ԅ%/]{���d5U��¾JQ��dR��e<\������enS'd�{\���G����&��k���6�bB~}nb���Os����>��L l�m�Ўd��6��>�4��������yݩ.C� �Q�BqD��O��V��L�f�����k
�6C4�֗0���z�/�&��x�C_za_PqK�`/����t�u�Q�t5��o��4]��@�mL;)`l{H3��P�u���������
h�M6Py��<��8�
��"Tr��1=]E��E�9X��i��U�ɫ�C@`����ŀ�l�-*(،�������XD���%'��9y%�a��c�3[��E]�
���,4�4��O�~�,�\ [�H\Y�S�D����G��� Q��E�&�S��k8 0p�n���=gDdBwF�*r``�f����ce�Mmar=� 1��	x����GN�l�Ua��h���P��e�����xR}���m:�y�l��8[�d�;)�Y��g=�uv�S C�6��1�a�M����g�Z��W?pA�c"�)�鐯��Q4�n[x����}TL�0������(��)\Ô���6�Ĉ�+�e䡉q�;�-��M�͝�1;p��r(O�ƈ#�����k��hb���gٷ|���Ȭ�iSd�������{?���D�)��(���¯F��ؠf�j423�J��w|�q������ӃG���H)ɛ[f��J��ց��>	F��0ڢ���qp�"'�O���.�~C�b�s�r��H��գ��&i����ǌP���x(���ľ�a�g���ĳ� B�,�� Ql�2�
��r�c"��}Tf}50̘��}��ug ���0�� �Թ�}������M��d���d5�?N�I����#��L;���Ƕ&�0,u�☱����$��O8���� wU�}ـi�=k�p��!qX���='s�C��@ߧH�F0V�&�o�۬�X�������Kd��I.@9o�$< ú�P��0�������<��	 bW��J�=�4Lw27ҚrӼ��җ\s�xV{�@��FC����i�����HL$��>��	��ԇ9���[�oLf�����@ �]L(���b�Ap����Z������~Q�?/��w������Oe����T:1?����������W޻�����;��S�>��͸�L
���+|2+������ͦ[ͬ�22N�8�Nf��DR���T6�73�)���J���]�'�rӈCb�7��v�B��_"k��;W�8n���(��\���ϕ���ɥI$_\�|i�'�ޣ�'��Я\�V���]2{��܇�(�7B�@�� L�;��b��{6���̳�
���tv_�y4N��O&����&�K���_@��WPb�����2��?�׭��-�o���_��������|�;����B�s_����܀{t��w/�����cwz�GS?��L'�*��r2�f��'�d��&�,N���&��TR�
)�ZVyAH��嬠&�\E�J�{�n������|����\����m~����c�� ��8��x�?��lL����Џ?�e`���0������?��p�*oUC��A��B����$��EH�Kk�
*H�Fi�T��ʥR��_(���{���.Պw�����훮~7��S��v/_7�������f�V+����r��q��nq�V[�zww���F���Tȗ7jª#�x�tS�nC�_��h[�_�l�^Iz8�v���������WX�N��L�5�[)����Z_�׭6�RΛF����q�E�ڋ�+G�P����k���C���6�����~�H��oWv��nC�w�z�'�����Uܽ߷v��fW�뻽U���K=�CH����N�[��rX��V{`C��a�J�^w'�{��5׶�]!���Z��9�_���J�\=�I����a�h?^k�%��(֔b�-J�AM�ӻ�����s�t�qw����tb�b��0��Ov-g�?r+��v�����������̓&�9Z]�n�Oz�x����TG��ʫ�^��Y�W��z,/�ܷ׺eq�̂z�Sw׸�*�C�{����{bO�ǎD�w���J�Z{Mv�'Gj���5�'�.��n��1���Z�9��k�:֓d���W-�e],�{?�o��]Yj�]��]�SG7�{�i�f�JU)�m��څ��]�N����[�n]\3��C��nl��{�d���Z��g+�QӐ*�����S�i�X�RZS]�x��N��@���惌fJzmz\=�H�Ǖ�f!�rag�ܗ��:S�v�pP�4��.�'ߗ����6kS�h��k��]�яv���ZC|� ̆���]]��Xz�F��wvv��jv;�f2R>����/V���6ܬ����\M�s)�m.s����( �$�UUSTwuWw۞���E����>�9�}���M�;�\�7�� GwU��稦�k#�>{�ĸ:r4�tbm,�)�Sƭ����z:�Xcn�0�S�91�b�T���ql���mQ��~���S%n���d�/J<�8� �'mʵ�c�dg�jgQ�2Z7�լ1���Z��U����a���׳k�V��FP*�g��X(k#��٢������66M��RB��!$_�XOڶ�@�� -�^Yc T>��Ar�OT�dn�����9Y�ꓸ6[-g���v��F�
��BUI�ި`q��c�� ��*�yY�ɰ��/����sɲ}`)�-���"#Ȕk̭v�a����˾A���LS��Ee!.mQ�U��H��V�6�y�e�C��|C��F�0� /|��O���<�Q!	;�s��]k����њ�G�-~��;x&a���S���; I�y�Ѓ$�j�ɡIb��BO9�_ Ib��룃���r�?ݑwhқ9ڒeC�8�^�cL�2��x?�V�kU��p0�C\�* X!h`�4Yi�d�O�l�����2^��ӏ���%�0���<`I�Fض�m�N�j��C�9�P�cb���׆�:�nI��!���.6#)��!��ʼg�l���H)cԄ�A�΀�0ժ��F���~��v���ۛx?ۖ���^v6l������_-�w��/�??���_$��F��/@o��_q�ow��!�	���B����om.�v_���WGo����_~W�9�t3�P��K�{⇿:�w����^�(|~��_>rY�߾K��ա�?W��_#��s���?n��[��o�������>Je�Ñʆ�m̗��a��䬽&2�.=����o�:�W`�b>����N\�&A����_1�լ�特����̅\S���u��}�\�����|�*$�(�	L�wn������b�@'�Ȩ���T���JQX6��XGX�IZ�ڐ�aZc�ʃ^���f?����K)�v}�e�:tg���Y`�隠q�2���މ����9�'&�� �w� g��L�%���._8���ap����IE�Sd�Ȗ�#��B�b,F�{��!?	��V'� ]w?iv�f�ڳYCM�ː�n� |���p6i�r!�:hL�h�VqswDN�b;�[�X!K��N��z/3�ɛ����h���<8e���d�=��M�.���ߌZ�������r�)�����tNY�i�S|Dν�#��)���kcq�	��6]���Ǆ�3��<����;r��Ǡw�����2XӍ.�]G�ZȃB��(�J3����Yo�=)47Z�/���j�Rqbz{�Z��D �Uw�~ܚ�Y�h�V���r��'��h���4U�.PA|-��k�̫ ĵ��2�x=���f;�Z�z���Ju���ަ�X�U���T�Gp���;>/)�E�6����#�ڛ��-7]��q��51�å��VA8㙽�bu�j���&Y���7᫁,2�s��8v�MCq�שEY9�|'M�_��	�L��6���v�/�݀٨�Շ#�P/TI<�$�X7�dW9��)��!U���	��!�S0Anu���}�c�`�J��)� w=���P���85~Y���&U�Z3�]�:Y�|</o��!��x(�K̞��i%���FO��Eg$�Cy���a�N"�S
r�(�]�+����!�]��c�W���N�.�s�52�I�j�c�s@��Q=0��
�v�v,�7A���`;C�)N���(&�K6���g�X��]�оX������5´!��3�u)q�K�����|yG�~]��t;_��u��_C�J淾謁���F���0ZW�a���ė��2�u��&L��)|�|�,�9����%'��~�����~��ߟ��=���5/��_ ��3;����K�0:�4^�!��,�[�&=:+u�����j�ɖU`�/�h4K�=rC�������Ⱦ���֛���{�G��|��|s�8��H�����!�֋d�@>���>x���O����k�{��F1���޷�\�}�5޹�	���iࣴ���=��	��
^�^��T_��z0�"�����Wm}�'�Q?�.$;�0�g��?���	N��^,�7����?S|��]�&�ۄx�h�'�?������#������F	��i %���UvOBd�����������O��R�2뛇���?s�������2��v���b≀��?s�'(8��r���}w������nN2�?m���o����4~��p��T �6`�L�x����{�E.�����4���G 2���[��������T���x��\������?�t����3г�#��.�?�_�T�E�.���?o���'�K��C�Oy����p@�ȅ����C�����XmVۂն�Rm+��a���f�T���Q������[������y��  ������� ����?���ȅ�C��2B��o���h�v�����?o���'������oJ��;4�a.:(3C�vXg���cq�t<{�e�u���9$�xހ���P���GΠQ��s�����:���}��a�:����-�s�E������KU���M�s��؀��4}���A'Pa�7���h�M5�5�am�ڲ�G[���H��Mu�54�+�v/r�v9,�}{� ���xw���D�l�3��@���_#�sRNt����e��˵��NPa��~�⦲��s�<�X�3;d��)��������y�X�#;d��ׯ��h���-�����e���8�WqiSi5q���P$fjŘuܵk�?�5xfU��g��_M�LC�aNfg�h���l�u���6ȑ7��vJ�+�ՆѪ�SZռ�P��
5�G�d�+���i��|h�-���E.�?J��ߌ�i�w�W��S�T>���/���`�����_0���@����Ԁ�!���/��B�����������Ѻ�����@9��?9�W�}p�w����%l9�p�t ׿?؆�m�8uѲt
E��я��Q�XX��3l��"S��U�z�U\1!��Cq�d��l!vg�j��:��K���Pk�u�k���T@^�����ISV�� �WZ�h����9_�p�#\�)�=���դ�p���$9>��5r}�**���|w%rG��G�W�0p8h�j=�0]r*��cq�j�둻�̈́��;n��#�G�Jy_�x���聡��d��!�fG�qÑP�Q�٠�}��.��0��P������>��F���������H������_RA*������!�g��8����(��4�*��
��CZ��������t ������_��������+��/%����>/����[���q��+\������K������
��?���p�?\���C���G�p������������g�����/���?��	�*�����_��/�y����
=�ߜ �>�F�?����o*��3��ap�*H��oܝ��1!s@����5����4��4�-���Y�?������e���f�d	����3��b�_��/%��aZHH��ߵ��J���� �?������A��
��a��ܐ� ������
��e�<��g�a���\���?p��c*x��B��qg�ee-j�Q�`.�;��j��I������K��<��uf��3��Oi*o�An~9瀔���n�k�9����V��)��BQ��e�Pe����!7,!r�]�1a?腭�JtF%ܩ�7V��Y�w��� I��� Ițr@Z1�[G�nզ�+.���`+D��ȕ蹂WL'ċ�J�n��e:/sT��4�h+���
lm�9vJ�8��M^ӵx0�?;��ȅ���������,�%����/�O]���H	��X2u���?P����?�����#���?B��_6�����?o�����?3��aq�ԑ���3���?������	�_F�^�M�}-�.t�Y �������vY�%!����?ɒ�c��Ѷc�e�� �(t@���=GˬKa����y���e�>��?���	#�OЗ�����;��ْ;G[�}M���T�TN���J2T�=�.����X�r��؀��&�g�����^����LL��q�e��~��x��ۋ����js_�/�x�����rm���ז��z�O�SD�Pr<Z��mk��P�� /���;I<�j�wE�[z�(�&:֣�߻���?�!�������h
'}�E�?��!��d�����e_m`֟�sD�����!����L�Ѹ2hJ
W��P���5洹�գ���Ғ��H_��m�{j�6W�r��Z}3'�%>��5�B���;T%:̠����^�6D}�Tܨ!r�`�Rs���Y<��nN����-��/�P��>�;�+g�)~�?�b����0����/������t�j�L��GQ��1�g%���o�_}�,ik�mz%������B�˺������O�����'~���"�l[/��,*^j�~���dTq;����LJ�3hO�Fwm�fDC)�m�@�����A+��ڪ�M�<79�T�!���lW���]ݫ\�{��� N�C	���g�ܚE�0|�_�j�|��UTQ�8{FEE��[c��'qO'���Y�TMu�t��e��[��T���y�أ�����럿��Ɔ����;���a��Ҝ�c�e�CK�K�s�d[���\w�i����f�_鉮}����x{�8@"��*� �;Zbm�H�F�e=]����e柭�I�R�z�n�e&rE$�S�HxG���ihh~6��	m�D��u��4?p���,�����?�=����/P����^����s�KP�� ���/����`�����g6����y�R�$oG�{��%I�L@|��׏D�� �	�H���B��]�G����?���+����ڨDb��@;��$(�di4N�]��Vًqpb�H�}����a�-j�>�@��[���x��g8��(�t���M^u���@���!���:�?ɼ��eq
����oS<*��'h2R*"���4	)N�8ɦi�є���I(A�GD𓨃�?��b��!�W�������z.CS�x7��m0?$�S��=�ɩ/%����r������+ߪ�����Z<�q��*��6{�T����14<�Q �_���__�����&y)��������h�������|�i�����(�����:�?�y��������W�����@��?"��O��?��$ ���n���!P)���������/P�����������+��_�����ʨ��G�}�w���W���r�g^�@�Q'���?^~��>T�����W����/���k0�e1Y=�Z��7�y��_v-a��[J��9s�b����R�RvF�Eq��7��8ɒi�vx�1Z1���x�4�׊�L�%�]����c��ؚ��7����SsR��9d^QE��?Q9�*��o��L��>�#u`؏�`�u`��]~�;Iן?:���ìHL9=ղ=��Ű�G�"�ŀ$؉�����_��YZ�����m���Kg;�q�[S�mm��2ً�^g��Zcb�K�m�Ķ<&�����i`�f/[�S�W�V�%���,ue��S�W�����DŤ��7�s��s��-�ۀȋ���ъ�25�/�\�d�W���+��0�4���@���d�H��-���e_��-�|�͛Kw��&���{�$�K�Ҙu]v��6�\�Qkr1��L���2r68zCwo�����uz��bg��Q�Aj�b���
�j�=���H�C�W̲5d ���׎�j���Z�a�3���/�$��Q�O��k����H���Wo�?�a��u�GV�7%����Y�,��W�_��W���8~��RT��_�:(5$����5�����^Xj��2����:i::�stһ�6z~��Rx�e|4��=�2~He�����e�]M�>��q�B��q]��o���.NC���#g�gÛ3{�5�<��Hں��F��v�I`�F;���cr>�o�o9�0����rV�Ҙ;��5EZŞڵ�n�V�Z���Wq.��m���:�,L�ui��'钀���4V��j�Dz���p�͚3��htL1��c=5��h*��d�0,&+�6t&	����t�7���$õ�#�(��Lφ���+�s��v�lE/M�;�����>;˴�c˵�߿��-�"�{���u����@��������<����O$�L��sb ��:��|p��ߐ�3�?l���������!lA�_ֲ||i���������?����nCT�[�?�����h�� `/¼��Z���g���3m�]�=����ָ�r�u��n�',j?�|�q��yyl��i�"c� �qG�m1|��,�vڷ�e,��;��7e�̀�y �\�: ��Ŵ!����*��2�Œ�z�8��D��:[R�������u ]Q;�B��J[`bE3S�
�m����˄ٙ���`�.���xl--mA&��3F3����.�c1���t����ȳ+�wI�"��_u���ۇ��W�����B���WF��
 S������p����j���E�G<��$!�CA�Er.��.����_;����S������P+�'�k4�	ǆ)q<��)/$iD�|$�$�P��q�G�G�s�\M3l�{7u������#�W��q��v%#�5��"d1�'��!1N,�[.��v+�.�1X��o����Q.�eoLwqi2׸�蕼�a�a�h�6sf�˄qG��2y��<?8=2!�Hl��ù��<Y%�9�M����:<�a�guT���/�зJ����W����Qu���7��j�~7�u����+�_?�L�������Xl�覉�����V���&���Y�(����s��~x.�K��5r����lyh��Ǭ�&г�D�����NR����t�9�⶿5[�En�I�S�~hm���Ta,�o��
�Q����~�7�_@꿠��:�������� ��_���+��N>��C����,��=��W��R'Q�'���p<(�G^���<�k�:���v�Ю%����p�8��2��t��b�D�F��,=�&�0�5���V��f�Vđ=4����<��3";3��\�\��6�
�:Ϻ��/��s�0ռ�^�v^�흾���u��ඥҔ�vR����N��&��f��Z3����GR+��~�I��*�y��=j�+,�5����h*Y׸S�n��9=�D8�Ԍ��}�<��թ{���� 4���7ę���"�B7�u"��}#D2�6ژi$�-�h���m��}{��] ����X�ZcP�������?h��@B-��}��P��D��]k
�?���O4�E ��Z3P��{��Ұ�	������W��Z��U�	���@�������k�u��$���"��?�x������i��G��C�?��C�?���>1��/5��׎��������Ê�:Q��h��� �_`���W[�D�?�~���_������k����	��#��O������(@��p�_WP��{��)������������J�?����E�����e�0q�ǹ8�	2�#<� `YZH8�g��
��62�H2慄�"`��}u����?PP���_����E߸�d5�cf!9��e���ڎ�k�t>`�o��v+o2�/���׺�㇭����W����V�n��Ie:譼��E�^J����A3]���Nh���z8�j����R��?���O������� �	�����?�A�u��x�����L��������w����?H��?����?���6��@�_E ���X�60MpO9>&��Ax�%q	OD	��|JE�Q!G�I��	A�AG �B�����4�(����2m�g��l�/��A�b���n����	=kzTR$���<���v�ln��V�bť�692k�J��~�c�}�����$lbO��)Z��nؙ�w���M��<�p!9���Z�n�����J���������k
�����?��A�I�A���G2�������Bŀ���W�����	U�?,��������x����AB�6CT�?���ϼ����#�N����A������� �`��������a����vCT�����B������G$�K�_I�ϣ�����?"��������tN�s,'{1eI�,g}�͝�����_���}���:K��M���{�g������P&!y��e⥶�4�m�l�>�Ȁi�ޥ:��o�r����꒞��|Z�z�ylJ�&�.���P]۬e�J�dﱿ��D4����+���)��q��sI�z.���c�>��6~x���@��=#����;�yg��뤕'��taN��dQ��Tu\Ň�L�9'�-g�IK҈��1�F��VE���g�|d�V�d���p���/ �?�Q�����U�_��_;����3��	5����:��G�h�?
`����O0�	�?�U�?,����r�����_-��e�L���/��u��p�_?=����G���E��[���9nJ�9s�\Y,/X]�.f�������hd���h�Mt��k���՝O9��{�X�F׏�$�V���]^&$Rq|� wU8������p,����$~�Zbp��tҚb���KmY���\'MG�{�Nz���O��ϯa�\
o����2��\���?�e�<{x��8K!���M_q]��o���.NC���#g�gÛ3{�5�<��Hں��F��v�I`�F;���cr>�o�o9�0����rV�Ҙ;��5EZ�n�u?��[-k��U�MILyE���)O^_/S6D]Z����I�$`;��(��v�&��z;\n���0S̿�X�['�x&��+��.���J��IB��E`<�9]���3�p���H8�q3ӳ!c����㼝+�@�KS�Cl<2�~���2-p��rm��o�"�#���G$�!�[$�b��p������:�?E>���	���8	.J"�p���	i��A<�C>䢈�"����H*�p*b#��Op��n������G¯��_\��1?ͤ��l7-+�?�.�i��u,�y�o�P�����|<\���g�N#G���+��wo��e3���e��8���nm7ݤ�$���[%��n�N��wQ�q�[*�JU�R�T\f���^m�~̝n�N�������"_��������b�Ñ���l�P؃�V�����)3��81���h_թ�����jy	��:����^�}}����%����������?����/:��6���W^��_����<���m׺�A����iPt"�i��/���'�VM1�OOϕ\�٦���j��|���2h%�mL����q���|K#�IGS*���l�b�l�L�Ҭ�|켝��~�}��|M�[i}:����D�w�[��V-/c�Ϭ���T^���иb�$��������������������?k���?k�ʋ��`�w��SX�OQ�������g���A�٫�(sG��W�TM�]}����?K��������m;���g� D�ß�	ڳ� ����}ԕ��BK5�� ��(_��l�䠔x{蘙�o���H^�Z�H��n�|�aR?�5�;�j{��MI�4��K5�m!��@{U�r5�>���:�n8��|p�L"����ݧ�������������<�������W�0�L��~b0h�����r�����XX��(2�om5>73���Ȟ�G���@x|<<*���e��s}�x�ӕH���p�R:�W굏���&�T��7���˗����}�W�F����~�����ÒV>g�	�1��i%�/���<��~r�}ښ�ʍT�������k�������O�H_����/d�a���e�����W�b���6:�^>�o�8NJ�N���&m��B�G^E^�N��9v�)̰Y��2������4�ʐ���$ԃ���+ -ڴTfqKÎ����fhho�O̠�AFԠ��cކ���F)�O1B��Gx��G�#:b�@�T�Ռ"	�m��C����1S�,v#-a?ڤ�tsB��EP���a��� ��G�R��0����8�w������h`?
{�<�R�ʼ��s�w�;��� �G�X�3�lb3�3�cfО��19뚢9 "A��D3��t-	O�Ӯ��*N��!.�t�L4P��]���t��:읐FA���&�5�,:��!��X�vրٳ)�mk�Tu&&��BW�����8B޴�WW���I�C.���
��#6���|��8��i�x��*��\�D3G�eFAlKS�`�`�J�W�"���;���ha����,�����௯��Mp��u�N ��46{ԅ����Twa�}�qdp�>h�-�H B��w�b�������v@���~�4�6��OI���EC	�8�M�v.X*z�k�]�z���=�6@�B{Pg!J=j�����)OO��igNl��rQ
)���ȴ�T%ΐ��b1�J�}u�裺>� 9�Q_�7�D7���]0���Ԩh�D�S1]É�<��b���Mgr�X�� `�WB�7�|�_���R�*�"o:�}S����E��ه^Q59��8>��o�7�!l� پnD���	c�������R��'0#=�JxR���Na��[����ތ�8W��h��w���8�뚍`�s�!GĴIJ~�F�I�0�n-�pu}�8M��PC����	�s�'K�����J���;���jLU�K�2�p�H���MВM������\0+&�c���n���.����T2�Mg`�L�����>I��,���ב� l�9-��,XK��p:f�����d�7J��>h�T<[�Rcdƥf�����n�ܮW�*����Qm'�%����;���Z?5J b��jlZN`�- ���hs�:.{Hb
y=߳Xd@`1V�YN_K|)��!�])��6���6��s���%�[ɂJ�T�e�$ݦ����mVHn�X��T<`��tZ��f�K�<eg���O�U��S_sj\��;br����Dq���)0Шe֙X4n�J�3�ɖ��T\¾���x�ٮ����{�F�]:<;l��>�wT�s�W�w��F�Zm�:��d����6�ߩw�j��fu9eY������v�|m0�Yv���Z�cP���Q�U��H�|YZ�Zo�D/|KB�gdbZ`����U$	s�$�:Äm)�X:n����9�pi�	<�z�=�����dW�\�jaI0}G`@�r +؉�����<���Ň��~q�%�������f��̾Wo�-�x^��_�7*��|�j�|�����֨���Fw�5��b"��]H�Z	�5������[�j�|��w�<\��[�
l���[�Y9����N��l������f��F����YФw��A*(@�J�T@o���7���f6����tKݚ�[-uK�R��F�2���_i�T��e9&��#����^1���}PI����Ob�8Y��`U�����"ʩ���4>I�d�I�6q���f�����f�s���r��b��_q�*3C���(��y�Z��$�����e�z.�ݭ�<��9^@Ɯq�EU-����+��&`��:N8o�1ܵ�!���,�����9q̞��jܹZ)bk��/�Me��������I��!`�-tBŤFى/8돰+A��wƗ��֧j�ӎ���[��di8�	���L��N�N�e��;!V��0�pw�|ؽ
U�C`X�}�W��Z>��� ?��Y�������)�<�O.����Z�����?k���������?k�������<��GR���v�T�Ww ��=kw���s����a�R͉�������},��SH��_��t6��������ӔWK�4#ѣ���kWi��f�a�eZ�����P]����`�\�A�*s��Ab�P�O��"(�;�ty`Rl�O�g�vR\���VXA��iM���o�����эﰆ�u�'�J��_�Q�%��J�>!���P��v�[3UdG�ͭa�=]G�reD�\��k�#J��v�xXld^�X5�spYsX��;�O���{�j���'�'1�[~�F�xzIPR�Nb_7�Ӆ���v`�ٰ�N��3j���V��1�? �X��.���:�Χ2k������$�@D���5����>%``��]S���@�cu�/����Xk`UE�D�sq����d�x��ɬ��')A�_(����ذ���$�#�0eh�h�����e��?bCO�|2���h/�k�E�AD�O�l���������^*�Hu���]�)^�z�4ywF�́7x��F��(�:PM�C����0���� jb�t;	BM�Ʃ�u$Ң���J���-�-h;�����I��~l"���P�,)���ta�x?��_;l��M1�O~�M�A���Ć��N�+�P�;�y�����zM��fB8��Ѭ����\�̦
�'!	����7b�&��D�>4�7P�;;$�У8~�O2�9-���^Q~|�I�ʐ)b��$Vo�#0�x;�Fy�B~�L�S9�di�&�{�k�pu=0�u,����ۍ���ʛ���T~�v��yN����JR!���0���
5�R���/<� .~�x{@��`�L�wB�&3h�O�G���rbㅋ����!56����<�2�@���E�!�da@�*Y��5�D��QR\�,A�2��޿'��.��$��MmO���iD��6Q�h�D��}':��͇��^���;���%Pw`��b"�
�}ͽ�Qr�+�%!(��&]�#-��w3�uD�%$�<
"B��4j��9iF���o 3n�^=�k�I��s|���F��^��ҿ��X1�u�M&�� s�O$f=;�}Y`o���떟��P*����d�|��T
[��Vk���loK�Φ3,���T�T�Qhj�@�{���4�����qx�mm��/#s%:ST�X頤@e1�gr��4o�2~�fk.s����У[��+�v�y�m�tw�h��c_3����"��b�%��b�'1w�?���8u�o����Y����$�{��n̐��X��TB��0dAS�ә���<�~TL`�	,G��a�얩����|i9i�pm�Z��BX���S���F^n[�|�MY���.�)���y��&�j;�e��T67��%�^��<I�Q�������j:�L�i
ؔ��sr]n-+��O�F�2�O���O:�J�׿��e��������I������o����?M�9���C ���'�2?�8��y0��T�	1eC���ݔ(HPM3�CVINe�L`��G̴����wD�m���	��w��v��[?��~d�N-�I$"�],��ս��:c�[�v"�^̗���ǐ�)�Ę��Y�ߛ�C6�i�;�9W�{���Y<?"�����-(����F����C����;��ѕs���z�C�!�O,����ݤ�,K�?d�G��,�x�G&����$���?��GԜO��r�>�D��@x���|O"v��1�^��g��\wX����4�G_���p:lr���*����<���?��T����/��o1^)�(w����^�?�.�S�t���g3ٵ���8�1!ի.�B��Q~�����3���2]z��6O���Y� C��V!<�]��ɘZ�9<^�������i���C�K��.��j���΂���b�P���"��|SA�v�B� *ܖp:z�����uaá���&�\��M�Kz�{��\�.� Q\Я_�4�ܑ���	��a� ����q�Q���x7�	V$��P}�f�:Ѹh:��TdŜ���x#�A�3g!3�T����sd�t��7J��5lǈˣx�G^E�C'��{h��J��3{"����q�W]A���x:�'9�e��uz��0k�ȯD���D1N��9L�Q�78� <�$}�������'�q�ۄ�w#rh�*�.ܩq�H�@�O:��z��W� ��fy�m�j�x�GMFV�~'!��	PEr�;s�֛���Z��Gp-͙��K=߄�pkނ튢��^$m Վʵvd6��ԋ�N�/?<��B�¯��2���t�ehZx<�a__�f�Ƽܴ<�c?PA��A�	�-Ӷq� >hc�mu��A}`FW���gOƩ5��v�3�˫���i�������(��	A�＝9+-�G���oũU��fc�3 K��g�'"�xX$��O�>6l*��&״�',��̶3��qVa)���_��B!�.�EWA�D�PJ��}]�m%��G�>&GmS7��)���*�'d��"�.���l;|I�6?��n�:��]M%�#��ʕ<F<���������PJzؖ��P| i;��}chg�e��\����/�ph\28�.�s FhE�W�H����+m�u `��i|+7z%�yI����J=��k;v[�:@dA+���~{X=\�D�[�@���Ҩ�Rg(���T��z�oo��r���0��zc�Ń�GJ�c"O	X8��z@��e�<50*M ^Hm�lF�3��Rir )r�rR�\��\ a�C�uHO�����-�q,-O���֞��i�sۂ]���&3��%4���8��8q�Z9��8q�{�d4�y@H�0�-h^о�������V ļ x@+� �vn������ꎳ��Z�:>���|�����/,�h���V�.$�U�}/�1��b����&�{��i%���)�BO�b;9�J����/Y>��KҬ�ʑ��Do��&������+�`�#o��7U�O�O��-;�S�m�ݘ�m��7���Uco��|W�?��;3w�=.������B��D"��?��`�o �{|�����;�������G����|�C=R�k�R�F�!�5���(�Q�P%5Ct���*�jF��T�(�V�8��m�����!�
xi�B : /z�����8�ހ^��џÿ�}�֣yx����u�����w2�ނ^9���s_y��[�KE׹q��Л�]�җ7�u��V�Ϊ`]���ϫ=��-�����#��.��%��X>��	4��� >��>#~�g��ƿ�����&����?����?��|�[_}�����	������[�n�\�W��ͺ.�����?ĈH4R�5X�"u� u�#Y�GJ'p��܁c5
�u<ZGPohQ
�G�_\���������j��?�~��~�S'�)�Ç�Ӄ~߆�߆�z��50��з�8��A��:���WD�;���}�)����>��}��/��M����ȡqA\�Ų��Y��U�D5݌F󡑕��:>l�����a���V:�(�b�^�Xp����ic�V�؊�Ԗ'7%�|�U��ILw�[V-���_����s�Z��Rp�U�ܲٲLٔ).M�9�X&�-��UP�����Wy�Ǖ��^�Cͪ�)eˎ@/��yQ�W����hV;r���)�vgQ!�O��k�T�����S���e�IYǉ�:�r���ϯ(��)�W	�YZ�$#�h��)̓��"D����0$Γ�ө���p*<�+��Q���0��GrS�s=kh�#ZH'�b6jWAs.�$������	�"���$��Ǎu$:�N�+Jt9���v8gQY]V�;��3�9�[��U0^4#���>9�8:��*���PI�N��E,ug���n4{}�t�e.�^2K�;��V�5b�oH#0��>��<1=��k\y�L�V���Z'�I1�e��'�*����� )�t�JC����)m������zS�=I*-��vA��a&6�H�˷-�LR��ܗ�����J��7I(핁�$���\�P�q��Wv�q��~�T��	�c�hr�(H�=ͩR����r�,'�-|DpMP̪	&n���ie󍲖���Vϙ&.���s���#šT�d�
��b��l�*��h,���y_|G��6npW��tmL2"C�A6�v��~���k��N`V $M�qL��gS=���YQa�aR! ���Zֱ�6��"nڕɉ����y�@M�z���$�91�w�.��xё(r����h�9c1����|��(�3�
x1�Q��?N$��Ҏ��<�ژ~RR�,Ŵ�!��ʲ���A}1;��4�Ǧs�ٞ���J��M�l��LOԉ�7 �������k�Sj6�bl���G��
U922�JQ��Z3k"�]�G��j�R)A�} �E�����U��U�2��v{NWk�
q��k��$懬t�F��)� ���ɼ�F�Oktk� 5�.N����ǚ��`Tc^��`��;�!���.ʜ�Q"��mV�K)��p�o�:K'&���ӃZ���5ڍۙD�A/�8l�����]��M� ����}���K���R����g��ƫ���?��:,VZ�~k��z�3藡�]��`��o�W�«����J�;p������Y^�n����KN���M�iE�wބ��5�����k����?�}�>�{�7ǽ�?���Rs���ډ�G�IZ�L�)�d�̖�z�v��k�Ӷ�G��6�EO���#,��������Q͒k<�������,�KqxcE]��4�$&�f�G��
x���*c�V�BdN��0��Ҵ1G����!N�	�H��^FZ
��V�$�T��X���!�g*f�Y#h�S�k�^�M+=�6��RGH��K�H�%�N/Y&������׌d���0F��~�9:�����4���w���ɰ�V����ÆI��[��H�u�.Mg\Y�u�EZ,��t<b(9NsO��Y�g�L)VE�f��) ���H�]J�
�jXv�y�\bHմՃ�
�@�M�֛���*;U[	,\%+�D�پH�楝���ru#��r",���"�S)>�J�q3;?c�{O���%F\���i�,���Z s����`ӫ�ĩ|D��3���d�=���[&.˸M�Sh�uw������E�W���?�]-Zc%v5�]�y"2o�GC�(dFC�2�Z�ձ\�p�m�t9������Ź��0�dS���d;
q���"fh;j��v�"�D�ܗe��c�uZ���P�B��h�I.;K�aG��F�3��d0��Ӊa5�!���']�N� e�}�`���t�T��f�IK�8Y+E3z�R��b[��{|"GN��4D���+�f���aNŢ�x��f�ȓt�fϜ���H;#0��
ލ&��O�����>!��!��I�t��]2ɱ�PL���"�U�T�����W�d*����;#Ŝ�1��Yp��/4&�뎭�I֓�k��}��J.aG�|��d{�!a�2<��I�����=�ҍ"�T��h��<��͢�\Y��(�Ȅ��w�XĚG�D�́gQ�kP�ڢ�cP�|���#!F��sGӑ��v#1	�<���i����Iq��n
�6Sf.� ����t���B���t�DM3��0�u���&c����ex�u���ӑ2�+|�ì�Z�ԊT.�Yi��δѥ�]�+��\x��K_�^ޖn��Ѝn��9��|�6���������\fņ�	��Fsu{8zh�{�𢷈fS�|y��zz� �{��!��Ç6u�^�^���n�'3;o�WY�
�e֗sH7���lҥ�R����^\6M۠-��^���=XQ��=�_Y�����	�E���`�����W7�Epo�8��H���鱾�/��xa�/�M����>|�]`W������������g�k��&��U�q��t�����"�`��N��*�ѦE�����u�l��hе����^̸w��Fô̅�t+�Gu�=ny�es����.=z��#/��k��{�F3��M�07W��ȋ�g6�U ��\�E�7��r�pC?�ؾ�,Ա}�i�c���P��M'��O�3Q�[�p*�ؾ�\Ա}�ɨc���Q��y�Q��c݅c���?~/�^��T�6R�}�*��c�����O!�G� � ��� ��������^�����?�����)w��W�~� /��/Y��ģ�/� �]`K'e�LJd$���.�ʲ*�t���5UHHӢ1=a��L'rt�BE�ڼ^g+�qA�R�n��zH2�j�G��c�IMg
S�m������=�:�d~j����[dý����ӓ��'�o'��K���z���Ϗ���?��������̉��`?���y�_�'�����P�@1w%}�ab��y�PQ�T�Iv�0e���]PI�8��t9V���%pzm�M*6:n�Z����`�����I��\�X24/`�ꆪ�q`�v~�d�.X:�/�јi�͢��v�j�Q�F���x���*�wtFjv%v�}<�b~���k���BW������P�@�����w������N���?�4h�]�Y��v<1�Wm��A���A�?{�������Ox���2���8�����1�������Y�G��v��˔9�ua ������0����/���� ������>����w?���y���!?�������?���N��_Ӷc������$@���������ǂ��;A�/���{��}~�ا����9�?������� ������[���c���w����3ǃA�a/�9��A��� �@D �#���}�^�?>��p��.��Y�`	�����[���c�Y�	���_���=���'ϙ���� ȶd[
�-]'ے�=��`/�_���?���������[�����o�� �����������������0�?���k��;���?�������#ș��8���	���k� :\��u\�҇�D�ڠP�5�z#�u���H#j�F���#8��LF���5|V_��=���#�Y�?���\���ӿļ�s%sՙʖ�@�	O��(Iij2�^�M�Į�����H�(:K��!4����a�bh�4��@f�z�'a"�%���W���1~D 6�ؑ����h#�6fb2�Rm��%���~y���������~���L�����������?�y��\7��O���>��������1�!����͠�p���C&CU�EG6��f��Hh��rn��%�B;]��j�S��Y�/t:HI��Hx\�&V$*L�cR�Gj�~���'4F�[�Q�]�E[������ء6e����*���G��_����i�����g{��+�����_���`�W��+�	��O�?��{��p����o�4��B��O�_Z6F�74�Z�*�1�ɑ��N�	姮�N�c�Cz�6sJ2�Ӄm`{���E���٢��0���]I��J�}c~ś�֕����
���� {QP�_�i6u�J�[�u+��ʳG���掽#�9�ݛ��ì��Q0���ͨ"�{VFq1�줌��ԥ�M��$ۚ�u�I�.�sVh�r�CCΚ�}G0����v��?�����V֨��N��\�7�oS����y��T�P�5����n�OZ��\D`Wѷ����1�:O~P�|��g_5_M��*�^.�|��0�g�5�+,��~��kc���6=����)�&�+YV���뒼yϑ}����u8�b�-��'�v�?^��G��-����_N��_< A�3�������\ �����,}7�Q�$������<������$�������0��?���Ż��0�p��0�\�������g���������s��.�{�������B���������@.��n�G���/���<"�����+������ �`���	��`�WY�����	��	���~��ӷ����?D��`���� ��|���ք���_6����_�J����`������t����P:�CeH� ��/���������b��BJ.�_��f��'@��� ���C������?L(]�e�jC���ϭ������A������ ����\��������q��x3���n��Y���K4ܤ��?��ג_����J^�S��p�]�����L�j@��O�Ԁ��lWS��=��4;kʶ�ª(m�I7m��]v�$�eU�Ώ[�1��8��n0��a�T�Ģ��{�B���@��5 ԭ��ԀP�"���jѽ:�asU�)f�z���|1�E��iPӝ4��ʬ�)Ǎ{����mMȔ�k��F=������Y��Y��Q �� 1�[�ͧ�����y0��?��t��!K��ϭ������O�aI��!���`�;���#�������?�R�4�,��?��#��������C����K����������p0��$�����9˷��) ����	��1�?r��8@��
/����XD!RdM9:`c�D>`6fYZV"�	cItaHb��;���>���'����{���x���w���j���i�_��UWSu4���;�����sK�_>.̺f���x^җ&Ro�o�5��҅X��ϸ�Y��l4���s�2몷����rގ�j�T�t��}��饺?$�Պ���]�҄C�=��"�����w��d���^�#3����m4�z�壿��݋*�����YJ]������������t���]m`ٗ�S���W~��K���p����U�4eT�<.4w�s[y�e�q5Պy��^����������4M��:l�UU/�Vs(Pi~�aDs)������n.��OQ޶���HL��Ym���.VY<:mx�ߏ������� ���@����
���=@D��J�A��A�����+s�4`9 A�	��$|O�o�/����Y���ͱW�
������ź{����W꿟�H����,��V����*�\J+�����yu@A��բ��2W��P�*.&���E�7��gk�ݨ(~|P��Y#�3�����j�k���2���<�E�{�y��k���X�<���=��R=����m�@�Q�@�����&~3�ek��AC6m=���v���l���u04��������_����7�r2j�¹���/_[���oh,�k��D�n�������lf���`}��J&g7����N��V��u!�/�P�[3���fs�6fA�>I��?�7V��N0~4����?�?��F��_ A�3�]��H��/`����^��������/N%��8 �`�����_������C>�DYfh.�Y�v��׏)�� �d$�ׯ�W]0��E,#\ad��®���=����>�Á_�����uj1�SP���S'�G�f��w�=m��T������K��˖�j�~V�@��GA���<Z���>���z�C���q�߿��_� ��� 	��
w��"��� ���[�C���r��\Ƞ�ü*1ͳ4+�q(�#N
�P�(P�!3�Q ����������b��I~�;�`Д9��ǃ��C�C�8bG��);�hы���+�M+S?W������(�X�i�J��&{�
\��{�8���/������[��/�?��%�����O#�`�~�����"����{��p�?$�?F��P��	���n?���	x��'��F��@��4}����� �?��{ ����|�����0�d��M�)�|j ��������4��!z�]���� ��/������L ��C�׷_���G��c�G����W�!����y]W��k��3A{&�~%_5�z$d�Ќo�9��xYA��a)�,�b���/�e�t�izl-C��1\�o�{Ί��gkۜ���PX���.�����o�9^�56NO�6D:��5Dտ���O���ԝ/�`~&F�m�[��%vҮ�?<���|�+�2OOY��O��Y�^���cq��r�U�K�q����nVmU3s"�E7N�&s�ݙ��*[E�Zk7�a�^Y��R����+�������rc�FF���ܢ]�zKeYkG��"^���qԱEi��'�kP���d�Po"/j�*�M;�嫝��I���C_ݡݚ�4�b��ţg����x��g��6uht�?��ډ~�/�+�kcd&NN�y%\*�/�+I���44Ɨf��5Z�� ����]����1�~��/�M;��&�Ŏ<�z�?-F��{4����� ��͓� ����[������`Q���I�	�� ��_I�������������o�?���f�V�Ӫf��#i�5�+��+����/���^�LK9O._7JX�T7T���o��j�>���B�釅��Y�o����o�-��_��-��e��V����f+#v4�y��(�W�����>ީ�&�?U߫��j�An�4����^�l[G�����B�EcF���Vߴ�Á����5�fM{��Hi����$;s���8�ͳ��E�������r��Y�{[O�y��U]��s��p}�]xKGo����O�A�lM���ֲh�w��6j���^�9��<BG�~yYOEet�:��۞�gMO�t3��q���C�:�L*�aQo3�rԧ��NzBSܮ��y��m��v�(ҡG�N����Y��8u�����v���̃�o�����Ss � (��?��#�����������>1��$��}p��߰�{��g���+_�����tmqaDםЫ��9ߟ������m�O���D��� �M�zjS�t��v ̏g 䧁��sO��kO�w� �� �h_:�aCw-�q�N۪L����d����yu��[eXg��`�f�3j��Eχ���|�O��j�tF{�ݦ�ł'~?@�ޓ�&[5���ӈR|�=^Fm6[��6R��	��-����u��h��#���`�1bּ�E;�|��m��D��.oȌ��muԒԣ�r�K62�vs0���އjJ���q�����6���"����@��C�/��/��?��#������� �A������ ��p�������W B�1��? @�-�s�o��� ��s�?��������?���s�Ibӡ$s��J�| �
�r��<Et��t�YBJ�H)��	�Ľ$���������W��i�h���v^U��@�&mu@��Q�Z��긪Qx�6�{x��������n���K�R�2���j[	���K��u��P[E�?���<�gÍ���m6bQ�V�pn�>�#͙m��(HX���gy(y��Wp�[*HX����"��������u��e_�O��_y����r�p���~Q�l�)�WZq����k]���tN�YM�z��h����{���J���g�t�:^<�є{H��D'�T�wU|Ђ}׺����Rw��ct��V������m��)���~d��,���������k�;���������/����/���W��h�2@�����?��������k?�����?��p�Pߋ����GYK����jٯ����&�m�M,&��u �#=�����i?�V��Rى|�>N���3<55��pn׳i��5���J�"���a3�&ͅ�P/�\��\��y+S��w�}�f��-�{m7L^�����ӭ�o�ϯi��]�{-1k���S�C}�X��"�^M�N�Zǁf2s���H��[�)w��z����fv_,����v]:�N1�ٙe��(�����Q�8�֧�i��b����:���h�1���63M���2UTv����P�;nY�7� ����skH�����?c�ǯ�0�d���;���?8�`�/<�8��<��]I�?����2�K^��殤��w�+�_� ���W��
�_K���]���1���/�����$�?�2��/	��F�"����?�,��?��!������>N���R��s�?��y���0�(�����������_~k��@��c���<�?���?D������3���� ��Y�A�?���,�����7�;�����?��!���R��pw��_1��c�
���eZ��)�F|H#!$��I�,���)�2�Xv*+/EQ��>$��G�n��@�}<~���I;8,/v���l�g)a�������g�n�_D�ᷞ���u�`�&f������+�nS����)j�L'i� �y�=-־[�3��R $2���&�٧
�-�r��Œ��}�9�[۽�����=3�[f�4&��rny�ws��}��7M�&��|�dH���XP3�\���|mh�yf\��M25/��x+���O���x�?�?�>�)��C���������S������x�� t(�����&
����I���x�_��/��w��?�������С�?��E���̑j6�P;�T$5���"��l��a&G�Ԕ�JgSR��A�T 2
D9�x:�_�?��q���_=��MW7-����w�����%���KU���L�Fl�Ka���,&�ɻ��$g�U��h�6�)H�\cL4:�Vu���Sj���M����<�v�z4��AǞe~�"�py#�&?Y$�B�+������G��8I���T���3�������S����O��:����<,�b�������,���@td��?yd��?����?�g�'���N ��/C�b�������~����@tB��=
���:���������������9�1���A��?G��oC�b�����N�C������ǃ�I���Dq����}�@�b�� ���z�����Vto�\V���j��[�������ί���}�ѶN<�����=��j����0��UE2�P��F]����]g^���.�zd-u���y����L��U4����yWfT�9�liA�ݒ��4u�	�{b׿�l���^�	��Y֯������~�bw�xb�ǿՍ�"��ve�V�.��D5������Y�6a���h2���6�Hq�d�B��.����*��u>�p� �z�����;J%ϯ��5��Q�*��������s�/^�{:�o����n�ߏb�����N��{���B����)Q��S�����D3���������������;����q�c���G���{�'����4:-�g��������)�����������_�7��mxMs�8_+I���n��%̌�S̗�Qgg�O?��A}%ܳ�Љ�z��1�J�y�8V�)��ɽ� =ӹ!ϋȿ5�GtnU�7a�'������o&�s���T��U���a�zO��6ߛ�/O�F�'��i���*d�W����4�Gn��)'�X�φ2�M,c+�����a{�q�a�������N_d�
˕�\uŵ��l���Vm�m���p�v3�	1�����Y�Y��WGb��E����zv�/�B���V����dƌ�.i~u��q�:˔��¹~ܷe���W�S�X5'�S���N��W����W�
7�Ǣ��*\��;��_��-�](W�f�&�b�����2#�^������gI��}���������I�dr�}>=�''��<[��a���A~�+I��u�Ռ5o\��h	Q���|��7�z�%���g�٥��w�x��I�Ԟ����B'`����q-���(��o���?�D��b�� tJ������4��d�Rҹ����d:�� 	)'ee9'˩LJ�de:%�dJ���T>%������t
�������?������ڸ:]��J���XNni��W�9�?O-��X��Ӥ����售�d:��$L�Az���5��(~Q"F��؞ݬZ��lZ����%��4G�B�_k��5�i���Z���Ϊ"*������)�����ǣ#���O��Na������I�|�����?�7���c7�oH�����w<�����h=�*�/͡�պ�7�v���g5[���x<��]�X���j�LS�Z+�g����\��뒘�ON���2ϯ�9�Ȏ�K��t�׆ϕU������ȭa[`�*��I�t����Nc�������YL���b��3�)�������_���x�W��+�����q�?�x:	�/�}f��ұ�wz���#�O�<��oi�[�Yz�lmU�]X����W�GY��*���E���ښ��= Dp�O� ��ٽ{ ��*��<e�Z���� ��T-�ӯ���k����I����V��y1�U��J�hN��B��������j��+(��t�Z�
6���cd���i���6�}B���wC-�>�?�/�� ��Eίs��9M(r��$��64i�-'5���+H9�޵�!w?'�J.׸i��M����N�����I�;�&g�o*����y��	<�i �u��W�A���ޢ��)���̝�F�2��#�P����Q���6k��Ma>	�V���S�p�V��ݻ�0�k+�A%��Y�z���}������Z����
�g����t�!�1��> �Z�m]�����ѕ�H �0@�s@r�$���mn.j�M^Th���C��Q��:A�t(�ů#���i+�L�\�TuS��T`m `.������LK��/.�Vy.	 ~-s�/��x_��8��[9 P��n^�-�-�����Ϻ(�؅�B�4,��0�Ѕ u[�A�[ߩ4AQ.���aʖ�A�D���yS�7K1���E�7%y/�ըwހ���>u;�[|ߍ�D��#`�Dw��@@\@S��nC��C�u�ȶM��:@7����_8P{v W	 �(��;����"��·@��]�5�ƐC�'�6@%M ڶ��⛨\��C���xo��vt\$���-��
C������s�y��/�7	�_��I�GD��������ã6��P6>7��/AY� ��F�C��؂�yl]�z�~�o��qk��g�_���w_��w��?����@W�$�v�]&�DGmlI.J��Gm�UP��yP\�֨��8!���
l�,��-��N��ho����W-���a�kp��<�mUe��QZ:�S��S����u���D	U�]h �r�(�4{�$�����\6�~��L;�w��6P� ��j�-FP�ND�D�R�!*������F�h�a x�$�k�aY3�W�Ap���W�·H<��������o������7��0�J���s�җ��Cl��x��M���.���������}�+�&��d7�U�󦏿$vT�a!�~�F�Q�1-�=���@E6<iM=��@��I�/�t'��s��5�;�]���c��B����DԆ2������-�����$���q �K@E�H�q�_��ÍG�A�ֲQ;��}C?+���}C)"1y?u��q��t)j�ގ������9��Ƣ�v�/8��JT�I��D���?�|ג<�P��m�W����'�?�ab�� �s4h�?�1]D���Ğ`�'�vA��:��/�n[l�|��5,a:w��],lKՑ��G���%�2
�����K��ă|]h��|�#?MV| ����j���D6�+�y�9~0������n�-^'�>����h�J���`:��R���p����|�?]���� �ph�碆��zm*�Hdd��#���Ț#L��KݶL��>�Y6��ޖ�u�*	]9��]$�{^�
�����,b���ćｅ#��J��o�:_<���U�я�#Ҵ"��tF�EQJg�4�)�J���*�P���J�"-���yZ�TI�gD��A�Έ�Ό��Vp�,K��K�'4�p�Y���� P���'���h &pU�}s-�w��s�?ƒʋR&-J�D292��
ECF&ż(����Y2����()�La1�Z2��LRbF��a����/��\(���XZ�7�[͕��nYL^��6Q�؏��mh'�b�0
F>�ħ��I���Fo�Mm����AR]B���֚��0jW
�<��d�nOh��BG�v��D�ߋ���J�.������ג�W����e�r�x�V�*���bA��.T:ϋ�������=C�ꭢۗ i-ܤf-Dw�tl9�!�ΓYz�W�JkmE�(:Rq�9�O�C�~.����I���Üǖl���I�C� �s}�B(����������<~�m��7;�R���\A�<��9_f+�YxL�DA���ݤ����(���F��3��e2��q��R���gF�U�ٖ��M��-���Tx7�F�^hM$Գ��|�Znv{|�Q��nBo��T�vW5��v�w3�Q��֛�D�n�=p�I.���<v�P(�w�=�'�l��خp��\yRྒྷ�o��r���]mHƯ+�e:�c~��>��<����E�z����+U4��
S���.R�N�%�~��]���z���y��~��|�y���<
�+pMŹEV�Cs�4R�g�H`0�H���:J�}�ٰx�8Oz�ߣw���P���3��0�����C~�ť�17����E[�|�<L8�����E��4��>�J��O
o	���ЇKJ���Dg��m+<%fU�@۶�`a�D�ؠ�� ���\�w
Ѕ2�%�':��ِ��~�/�L_���9�lQ
�ݲg�xz,Jm���������� �z�y�����n��ᅿ����|9�X�
���v'b�3�]�GM}��p֎�<:.*}��(�og�aX�@M�n�\��y��p��M�qqym8���F��xtp!��F^�j��K&�ܳ��{�p�`�4Ⱋ؆J8Y�$���y0��xh
�^_]�s|���`��+�����,��4��a��E���S�[��q���`?���������L���T�F�O��T��������T�<X�(=�Xd#�����1�Y�=�q��a����`r�&0yd�^���da �a�������^��Hտ��?��P�X��<��,�� �H�6��*XG�W��h��mI&(��U0A�|��[�s���?07s㘇�/.6���\������R�/8/P�¸0��w��P�
����OC����m�����h��`���)Kl�F�⥮*^b���N���#� ���D��;x�ˣqg�9>~~^�p틪L�r6`��e".�.#�DZ` ��ʅ�hAe�!��!����w;j�@��Y{��݄dI��Um՞z����c�K 
P�B�{g'$!a��nW���x���<��pM��]&�:pM�c!�no�ݧ����IJ�����o��Blm�����51�2?��=���"��'�Ӳ�����4KumSL�O	;����C+�vB�s#mS#�{�Z��r�����2�-��J�ָe��c+E�w\SGY�o,�_[��)�b��U��-�wq�r�g�Yn�x&�<�xτp?�C��W�.��b4��T��g��y&�&�����'��Lt8��0�&�o�Xy:=��8RÑ)5TaxQ��zO��j6=�O�Y��AC�	s4f�[@�N�؇���1�ee����J�Ҭ7͍���U�;J�������Ӈʃ@ǲj�\�����syt��^W�KC�Yb�H�Bc����f�z��Q��6����	]�]�p�6c)�ə����bv�[;�>�������?죕��_H��=~w��gX�9����͛�/�LзD��?T�#�A.C#@Ot������%��ѫ�i���;�H��*�*�-�nhW���(�i��A��6��S�cT̶|�|����Ŗ��v�O�|D'��I��xƢ��t��:sZU�<�落|���G�n��`0��`0��`0��`0�=~*��� 0 