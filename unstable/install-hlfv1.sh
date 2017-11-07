ME=`basename "$0"`
if [ "${ME}" = "install-hlfv1.sh" ]; then
  echo "Please re-run as >   cat install-hlfv1.sh | bash"
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
WORKDIR="$(pwd)/composer-data"
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
./fabric-dev-servers/downloadFabric.sh
./fabric-dev-servers/startFabric.sh
./fabric-dev-servers/createComposerProfile.sh

# pull and tage the correct image for the installer
docker pull hyperledger/composer-playground:0.15.0
docker tag hyperledger/composer-playground:0.15.0 hyperledger/composer-playground:latest


# Start all composer
docker-compose -p composer -f docker-compose-playground.yml up -d
# copy over pre-imported admin credentials
cd fabric-dev-servers/fabric-scripts/hlfv1/composer/creds
docker exec composer mkdir /home/composer/.composer-credentials
tar -cv * | docker exec -i composer tar x -C /home/composer/.composer-credentials

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
� ��Z �=�r�z�Mr����S�T.���X���f���rv�
K q�,�>�fh`�0��B�N�NU^ ��wȏ<G^ ��3�"	{�|U6��믯_�w릮�mdd���M�p�4t[���� �!�g8&p�Oa��>����h��G�\�����`�4 xd�������J��Sѵ�%l1����"#s�a pׄ�����4*2�5�A;^.�T:���Z�.2TTo"#4��-)����tH [��6�C�ۢiH�)��u�f������r�t�<,dr���� ��� +C�n�;��x���A�Cb����Ŀ��e��H`4�!C�w��S i����ce$�"��j9��WB�O3Q(�m�@�-�iHupg����s=�6�׆�dڑ�7�`���ڀ5C��u��L�P��3!��h��-z|��G��E��z�<�6C�l�����q(�-h<yu<�
T͹�*��d��7O7���Kn��Q��m���M�+�B.� �����Hvb\��=��g/�9���eEj�0iN���ͥH�C����G�p��lKq���,���/à��N�_\�"��9��졛��`���胍L�Z:�M3��M�����D=��oK1��k�n���v�f�����kFCV_7��\���U��@�24�ϒ����e>�)���فu�����н�A��X,2K�#��a��"�Ƚ�d
|��ߔ�����术A��lt�#��<�<��H���En-����!TS�P�-��mCF��|
�:��+�1���	��w^>������k<c�?�n�����Uba/��x/�5��'�O��� ��������?���<�BK�m��,�a�%�?N��|d����5��0���Pn�&
^��v/uP��8���~�����G�'�1vt��� bt�^75 �,�,�q'u�4��.2@�����Y�0ق�n \R�.1�c�Ӵ@�6�eƭ�k(=|a�a#�d ��X�1𬁞���X���o4wB!�ӲkĈ�꣰t]5��<��Xh[-ݘ�9'�N�TEF�I�0״P@pm�Ę��]o��$_��V�T]n�-�Y�YSWm2�&i���� ����lE��!��u�M[�@�|�;:�5D0�:��;��H�#MV��&�$��ƃC�!M4�'�����������'r�ep� �7_3����9�IUS�;��
�@�Â_l|��Hȯ��U�_�c� "偆�Qg�Z�mEU���@��p"��i��9�M�+dZz��3�#��O�t	��	�1J�%���%�?���_��#������#�!��f=, ?�@/ؐ�pk�������+�+��څ���H'��ߦZ�(Ah�z��(f����F��&�&�#L�1���Ѩ�.���㶸�N�yVH�}vd�yL:���@��T�-p�YfکN���||ƺTy �+H��������qLi.�Z�P}�{�\�+ڊE���u�u`��@98�Q9�����HE��-En�J6�`竹��.N����Xw�ȹcΒ��g�Kh�E#��x�3V�^�F8��M�㹲&+xF��% 5���_�!N��!:C��f�4��.�MG&����������,�{�����7����
X��n�������:�?/
�I�/��?+GNJ��0�t���f��G�1CWY��Y��6B oX�э�ʕv?a7a*{��y9Y�Uv�[r�q�/�`Wr��͏>��-�$*+������\��8]*��/�GR�+�! ��f"���M�C*p�1�%	\�vݠB�&�MS$����xn,QTn��\�J��J.�>�Vf�zmZ��xj"<Yu�ٍ.����#N�Xh�ݭ?�����7iP.n��۷`sjŻ���O#���̦���!��N,x���J��'eɘ,��䀎!�Ê^~�l���\3Z��\�_E�Wt����597�w��`��'DcC����8b����������T���[8��w���D�������yu�0��qA>� p�q���_�>0L���aݧ����<7���"k��J����y�b�����'DUA �w��r	�9&�5�=��Z��0��'���{�w��F��߫���OU��V���ߛ.&�\�����
���/s)`���L���7,rk�%0��M5\װn�@��/@�P4�u�v:P��A����#�=����ƣ�o�������Ŧ�~���|3Q��D�l�e[��Gi��]�1��:���ӊ\!»�L�I�w]��[� ИH!���3ṋ�II{}>MU��J��,�<1: `4����L�[�X�Z�ˌ����\�G_E4�H�����1��<�s&���w�x�X���4�d��ik�� ������������ob�	�#k��J`����W�k�p�?��6�����)�
�>p�� 3"��q��'מw���\P\�/�;a�H�ݥ�{}�Nu�ܪ�Ɗ̟����2�B�X����Q������J`1����0�>�Z��)Hn;�N��#�7���o�F��W�`,�Y�~TFx�E��<R^v 0$�o �� �	������M�'>��uE];��P����� x_Н�ɵU�c�T={ur�=*��՚���hh��#r�8E5UӉ�
|�B�c��͎=�
�q�Y@�N�f-�C�\���$i�H�_�v�p�qچ�>�K����B��4b��?�O?��a�!��%b�p@�ƍ:�=�=�2������|t�����
*Q�t�r�9q��p�-q�|$d��Ⱦ�����`Ŕ=&�"��R�X]��sL{�c���퍉�-z{e�;+�o�0��3�9*厥J�|?}�{CK���k�D9i(M�R�	5�
���䐅�CIf��?����V.0C�x^��ơX�����v��nl�QCk�r\�(�G��u��a��!����0E1;7�L2]���զ��Ⱥ�� ��.�`��v3|j�[\L���ŵ�L�P�)�s�4x4=$��c�fC�z�?SF
Һ'��thD��b���N�f7&c�=_�(%�S��inը�N4I��<�V-W����ǅ�7�����W ����+����2A���?"N��	X�_��+�/���C0�-:J�e�h�u0�b�)6�b��/a�/�<����iAa�_࢓�/��?V����X��	�8}�"��Vj� :��(k�X�%=� �tڸ� НE���S6 ��+�Y�4đ����1�p�6����1��v�6C%�����J��%�/R�xHv���a>}=��{��Y�ĳ�?G%s�HsVd���z��Z����5�G����ߧ�^����������<��M�ٞ���:��y���Ą	�/�����*���o�s��w�~�����?����������ǟQ��ɢ(ķ2/�b6jQގǣ�Z\�D"�Ĩ��â�x$�k��PێD6��[���2��7��a�V�vU�9�������x�x��&�$u��K�;��������_�l���q"���wߌ�,�;j47�y����f���q��o�O����?m<�H�%�qJ�D�p܄!Ώ������gށ��?�p�T��A�h�ǯ�W�8��Y�6u,��g������~�y%��ձ�? BT���<Mc�+$ħ����?(�y��Ź7�d<������5sT�eYw�B�}d}NhL<@ ���
�x�r�\R��i�;-��%�ɤ$'�R?�����T�����A=���71EO��b?�<���g��.�q��U� S��Y����|��8���J�f���$ۅV-�vj��6<I_f.���'WR�8OId�ir'c�
�թ�}��Ho����gWi��M�U{�0�ʑ���]�$���+i��z�t�b��Zr!_���������JN8!i4����N.�|��'����b1��>�^�+y<p�w�D~�(dLxr֓;��i%}�O��_�ﴪ��s���I��)\Ԯҍ|��R�R<)Y�$"���刊�K�^��B�VI��L䳉��l9/ƥf:�L����=��I�����(���e��?�z���t��"bESxNJ�׉=��}rSK��)ܗ�3�^V�H>v;��Sۅr,g��G�虘d����J%q��D<���T?���d���))O�z��OH���t!I��IzU����|r_�%:��c�\"�N3J��~�C��9 .����ud�r;/�^��&%�)���d����b���L7?�*�H܆W��I<��Ξ�R�*k'��q������f9��;�׃����]�����]~��9��AN$�x�W/TK��;�.�t!5�����`(��@ך��~�=Ʒ�ӳ~�㝻A�,��s��>Ԟ1����[����J���e�� y��s�}+���x�������ՀONr��~���>f��>��ygt"��!����&����}]	ŕv-��9;���2��'��S3)$_����`��ȕ����K��j���W�W��=�:;IU^C�ǌxܮ��� �QQ�z�'d�f�u�Uuݮ
H��JU��Aj�¡J�[z>���N���ܣ�����_����X���(�&��HD\��J`���,�&1�jI̲J����,�"1�jH̲
��~�,�1�jG̲�3M7bf�F_Q ꗡ��7���Z�[|6�Ϯ}�ї��	����￯��_5q�K�տL����r]R*z2^J*ʩbSJ�X�HgRUXɼ�_�4�ɣ��.<�3�a�,�o��l����ǙR���~�����W�fu4���J����u�f%SRswׯ�M��s��o>��}7���Qֱ��������q����' �w���%��/����I3A	�uQ2OH��Q�M���٣���k(����?�x1p����N��4Y )�P4�F���;��:P�MrU֍Z�^���g�|�!?-~��	=��� �#� H��h;�_K��nB�-w�Lg���HFԐ��i*�jTd!����jm���`O7-��ݵs�y��[�b�� Kxؒ�Z�M�Ao�[�����|�~U#�,�=
�E���~Ii��:OG�K�X�E�K�D���`�ۆK�9�m���  y���f�'X��F�&��V>h�7:\:���(�hp@*$��]�� �N�3`�6 u����j�u��
���ۓ	�����ĸ��53;�g��v~x���af�L�{���f��v�$N��u:�ph�c�qǉӱ'Y=�8 �]v$�4�7$���pY�sA8 �8CU�'N:��z^�Eb���I�ꫪ������>�AC=��pz�)0���S(�'�Ɩ����ę9vi�A�`|�ۂ�[�����60hB�g�+��� ����*��!��wt�M�������w������R�'�W�b��X��v�� �B5�9 �.ɹd!��OȩjM��Uc���H;$m�G�o�0M��b,�}�rə�+��y�4ʝ���������2_�*�y �<;�$��%髻.>ޝ|������� b����%��$�����'W��x��E.1Ls?����y_�wKŐ�ə�����ɮcΠ�[�����Z�5!� ���j?t_5�|6V����~�����r�.A�ɞ�z�&�U�c�ѣ����و��r�!B
*6��3�(Tz�̂\e���`��M{���D���4m�j��;,�eu�\��� {�^G����L����2wD9҆�#�a;�n��܍�~H&��5�@�V×9?y�
h��<�9<2�;vjY8��]��p mP(ҭ$���;�<��(
�SDxx��Z���5@�L�o�CS�PC[�p�+�z�O%�����y��<��}2^�<��?�����S��ߟ�e��h�s�����g��o���7��s�w(�S��E,�_�{�͗￶�#|V�ut��bTW>�v"���@"��Si�J�≴�ĩ��J�b2��&�,�T����dd���_���y��_���G�8��g>��~�'��Y�O�{�~��n,�[��?�M��>EaE����w��u�"�oE~�w�ߺ������Z�_�E>���{�O{�͑�}����u����m�:W���L�u`�lQMZg-��#V��ój�^�3v�������[�Dh�+�=��@���3�{"k���Q����؝�Q�NlQY1�x�Y�g��x�0m�Ճ4B,��܊)����1�%�!:��5�w&\���tG٥<2b������;������@U&=�2C'��G�����-ʣ�D�M9r�5��Y[l8NA�y8�_T�:���7X�&�u�JuX.3Z�ꨴdGJ�|-G-����3����]-nbX�j3�j��n�21X��y�:w�j��J������|��P3�S/FY��V�Lo�� ~D�S �<��8��3Kn�à��3�{��/hu� l�<m�Z����Ĝ���-%���H���,w���`r��v��d���rz5Zg6��&��"�1����JM�I"g)=��:*ϴ�P81z�d
��͖�`
�3��)�����#a�J<Qc��b�|����/�J�t*���T�~�x�Yd��k�3�*�������9�??��F�=[Q�J�3���ڡ"jgM���+�/�z�(;�V=�=�S=�+ ���ݘ\���!|�s2�j��8�(�K�����]���t�-�zgKc��l�HY�-Z<)1�9��B*�o�D��J�v2�hs☠����W?���E���&�?�1�D�_��N��e$�U�����V���ϝK�O�)��*E��|6�R�DRK:U�mqN~�ikY}��ۥ��検f�Q)i�/T���T�۪N{5B��9�����<��WpYp`7�}?�{/Gމ�E^�_�{������g�b��7/��Y���𷉷r�)��䣛bMC�-#F���Jd�o��w�^���_� ]�b��~G"{�-�F^��4�b���'E��N�_�N�6�"?���?���?�������ޣ�?�V��WP�)`��;3�J������§')�߻����u~�c������|�s�`�x'�XK.�6V���/���X�a�E�����'�{[��l˗�U$|�
�L���H������Ȳ�ǯ�u�Y��+*_L�R�T逛���Y�Ȧj���HɎ�Ju�N�@�j]�h�K1�����I���ce����(_�taR:6��C�HLՕ2��Z_"p8V���;�1��=�J�Ũ�ô�pZ]gs,���Hg���3�~� w|�N۠`�C	�Xr�|���3\1GĆ��*E�cyFg�u9��dJ�F�c*&�'���
--���uk4l9=!�(W�I̪s}*:`�� a������J�hO�ft�҃�U���o\�49d(ˁ�\����Y��g�UK������Kd_������9�dnT�����M�p�βr�/+�pY1L�&�i\����e�݉������Ϙ��<h��rۘ�7S�Dx
�*�Wg�m��|͞k���kt�`I��q����M�R��z�5Q۫��Kl���]�1�f)8�:�5f��sg�h�¤���JE�*\eD�qe�5�s"�8G.�����#���-Ĥ��k	A�s��������Ӊ=���ֹp��
%�nB���0`D0;�djj�{������R&|����6��8�|q�hH�a4NJd
�B�+��f���ұ�fv@K1*FK�z�̔V���d�ŵ<Q��"Y��X���񉞞�T�-+/X%�̽XEb:�S$��o?�m�`Ă��	q�%_�k;�Je�t�W&d��
��y�W(��8^o��r�+e4k<QK�����p��,�ߦ3�n�)h4�:�&0�l�S�&Y�LURF�e
qc���u"�L�F��B!|��C��[�t?`���T�a���V�G�����J/zܔ��X��$o�PXzP֛���d]^̨�r�f�sr�]Ԙ��HtR����a�z+
X����f`$;"�Z��U��G������^;۬rF�����4��KD�	m��!����7¦[P��ƛ���M�
l�_"�y�hC����E������Y������%-'j���kī�i�A�}�gX`�M}�Fފ��G����S�ݧO� �7�7pɽ(/��ȫ�+��f�����h����!�En��mB��J����"��Xc̈́�#d�������y���+��[��)F�����kAv�x�FQ��e�V$�O���>���񍎗�E~"X�#^r�}�|���ȟ�^���?����R���$�/��^�s7��H���\?IzWO{��������O7��S;a�*��(�
9���><L�<�0�9S0Rm|]��"r�]S��i�j�w��Y��96aN�dl��f�w�I�ow���o}���{ù^�F��p'�eI�Ǐ׫=���6�f����A^ScP����tU��F�7��pjBoo��л"��t�َ�ƥ�'��P�9B���]��<]�A�S��A����Pr��"��5����wA�[h�����}cZ�����>^8�w�$����Pȱ
u�r��������/yf�2 ;A>_{�a�*�0y¹���`K�Gz�n.jax <��A�5z��!��·��}�a�޹j���������A��}Ը4�C�E��PC.~`M����� �ON����X4��_'�x]�+XA%� sA���̠�L[���,�N�#�A�qx/z7��� �kS}��'�8$&�(�"�7���j����D������k��W7F=�us��L�����c[���Q@�������w������>@25-����/��-��=�����|S��4Zs�y��a�&�7������Đb	$4buao@s=�q/b��N�D���N���8|N���1�ku��g�"���8l�8�����n1s��m"KZ�H�T5�g���m�ZJ� T��(�d-.�n�~�'�����/����C=��ƀ%]G�}�.��}z���?�۩W�[���L�ל�l��7�b��2��^0B^�X��d�N�a;#
H��p�k!�$mmBG)���SӰ���G��8@8��9� �5pcC��)�e�>�#��G�Ѯ
 ؉:�� ��P�p������3��Q��҆Hvq�_�WF�P��q���"�zu�vKY7qݰGk�Uk�*�fH�����/t�e�y���so��������6T���kA��{5bOtH��iB�6�l4�-��G��5B�My9B|r����C�`�Q @�u��������C��2�B�*U�?�Y��!r86�M�įkKLSt�Q����,����y�i�7�D��f!I�
MśP�:҉�<8�n���8x6�X�s:��Ʀ��܅���
@Hq�u�!����`��z�Q�?ϼ�w1�ٵu\s�?���[�?��ԗ�_�ㅌ>$?�?$DzϵJv�\re�>���pg�y�yeMx����r�9�EFzU�^t'8�&wl�c���UbGc���*�6��B���g������#��l� �V@?�L�4 r2��U����d?���zj�R�}
 Z���YZ��r?��DFt
�(�aH���[n�-���r�V� ��p�=��K>�)��G7F�M{�c@��0����@RY ��@��X"K+@�h5ы�,  �Jd�t,�ʨq +(��CLf�j"�R T����;ğ�|������n�!t=z���==�io�!��S����vQ1̸k^������p�W�fl[mp|Ru����|Z���1_~���L�<�Д�
�q��|��U����oSh��T�r��R�5Yw���rɁ�+:�c�b�&p�C�c��F�/4�	���U����TA�3QsbG5��E�i/���`&cZ�8V�L�_P���єѝ7� l��/�����lϸl�	��C����nc־{�d7�_��r9ɣB7��\��#"/��i��[���犌P�U�uN�'8�m6���|��U���x6���h�����4:��=���O\U~
)��գp^��.�&^Z�nW����jS�U+y�pZ�v�q$��=���4|hw���q$/f��.�#/�jp�,�A�,۔P�{��1�2M�qΜ�{E�\��+r��'�*�ȇ�l&�\4��%У(塇=|f�q�z	S����M⠓�1u@D��4�������Fw�n���[֋�1�-V�+]Q'�X�N��;�ڂwI a�S�nm��Z�� �%�ֈ#�[�qı��FV�8��T�Tt�Z�lS�/v���‡I���(*���]Ys���}ׯ�ީj4��j��@�Q/�4!���?��N:�mǉ�N�{U*�;p`����iN�X������G4�����>�o<�o�?I���Q����G�������ぅ�7G���������WY�gm4 P��;��g��� ��)�{��n����?�����/	T�2|Z������=������#8Ѐ8��R��?�?,��`��?$@���H�Q�,&Er&�u��"�`�pa��$�T�")Θ��&X1�(�X���}Ի�s����{����������^�\�j�t����jX?��Dm4���-��)#��Lo�Ž���/۟�Fݪ��Y_��0�[��21��Wa�/=s,�5��}*g�rz��yp���!��UK1��&~�Q��J�������������������R��<��O��a ��8�?M>��3��(�����7������_=����8A �G����֩]�K���_9�S�}��?`��O���F ���?���������� ^���#�_�ET��O��,�����P�GX�	�:aU翺�󧀅���B�`��B��� ����X�?w�����?̇V �����d��	^���[�������Aw.��Z�jK����B���,+��-e�2�9��~?3�y{��Zֻg?o����f?�����U#����>_�>��CS�T���2��پ(먳��;�L���짻̤�ܞCm��Vq.7�mg�oՖ1/��R��7�C�����}��e����Ϧ���B�'-:׏y��ׄ�����O�1�^:��r6��ٿ��T/�E}5\����+'Β���Z��Z�c�,
�iiv��j4'�p���i���܈�i���9_LctY�(s�[� ���ʀ��{�@5���s�?,����/��(��"������o$ �'��'��6���h�(�����������[�a����?��X���o����C���������5�����3=8�\��i:�����߸���~u��9����xt�Կ�����^k�j�4��F��ǳ����}�;���p	����0m��vR��Z�v�H
J-%M��[c~�v��!ؑ����y۶��)�'��ǲ%Oq��<�Z�\��!�BQ����)�/u�������;�\6ٔn�4a2�88-�K����6�L�Kk*�Q�z� ��+�rwpf��x�ꬢ��뉩�4���"CR/'mG�hmO��@��X�?���@�� �o_�|{�!�� �n���3�]�?'@�	p��hPB8�($y*�D.`E��$)�ɘ�@C1����BH3AH2!r��dL������4����Y����9U��z�n�D���ӡ�λ�,՘S�Z4��>	���G#wsb��S�Ϗ#ΓtsxQwGJ�5�����s�9���|�a� ;Z�%z�i�N��]�m��	�4��6����o�?�V����|U�J����_u������2`��Ͽ��kX���	��C�W~e�w�}p4��i3N��%�^��;�.;=�,<orn�m�/��a��>R�^=|���mig��>S��Ĭp�PU�K.��d�}�jÑ[��
�5;��x]�E�Ǝ.�&[��[���OC��"`p�����w|m����濪�������@�U��X���p��@���k��+��/����6o����s�(=���;��hQ��)G/���M?#�jk�3; ��b �}��*U��h.�J��-xu��f[�?4�z��o��n�%��3�Wk��]��f�Z���!]K���#�Y�jg��@;��B���9,$;߬�D�9��8��n>O�W�� p����k<pP��\�'!/ް0�K�r��$��n�F��T�ڱR���E{�e�nf�C3���y�q�RSe�M���Q�*�L���~�@([����$��qר�ѱ]�Jm:5[J�Ng���[~�ߏ�]��v�TY�R=v���Eexy���V��{k,�Y��������L�{� �G���>��}���(�����������p��|P���$@����-P�����S,��( ��������_�������$?�9?�I!�#��ِ�%��y��b�y1f� �m����D)f���y?�������_
�?H�+��np\��n�M�so@\У���5�`��~Ė�m�[������}-���wqݒ]Xۍ����%�jE�ج��K��a�%i}�t��ˈ'�!�R<}���-k8�����J���$�n@��[���O���@�	>��oU?K�����'����G,�����C�"��?Z���#������������" ������	P�����s��P�U��[�7T�����fd�.Q]i^�!��˕s�����k�������������c���~�J��?�~���s�ɏ+ՊG����<��Yq�����Ѷs�I:5�.�91��Jk�Y�Gª?�M}S6~�)g	���
M�]�Ȭ���=V�4��\Jǒ�&q��j�^ﷳm%�ڹ����b(q�w������n~�{ �o�t�k�����NdK���������'�`0�Y�/%n,���&h���I'5�'F�r&�]��K�ml����%	G����V�'Ӌ�J�)��}�ld�A�]����h��w��n������-�C#8n�!���́�@�7�C�7�C�����|�A
 K@�������ꀜ����, .�"����Q�� ����/����o�����$�?������~h���(��=�?�?���4I����?
����m�p-T������W����!*�?���O=�� ���?�CT������{���?� /�s�@��?��������?��ÿ��㧀���������?���n���sw�������XH�!���������?���?@��_E��!*���[�a��P��x�?�C������ �������������G$�@�ei��U��ϭ�������_���#V���ȁC������������!�O�G=��?�@�-�K�o1�� ��ϭ�p����������S�Ud,����!ř(ų��Pbi&f(�#��}J|)�ߗ|���e��}��3<�E�&�����5�?S������5��)U�d��r����Qt:��M�R�x���#ҥ&���V�UC�òo:�8�˶*���I͜���Y�e��U�V�ص��ւ8!��rxq�܅k�bn8j��4Q���p�=�tL��\׆�KGk�x+�|k�_C��'U��p�����:T|��+��V
������?����\���_�O����+�^�Xܹ�wE��1wD^��b���Ee�y���w�/�N��_�A��ݣ���:ۭ��anD��9�ɜ$���7��L�ƾ>����o����ܔ���������ɘ�Q�o������x��w��!������Gx�_�p������ �_0��_0�����@V,�����(�������>��5��J{;bԱz�7���'QI��7���W�gmw�v��)^����:�x������ �״�R��ۚlQ,i�~��,
��y���d̓���a?1�B.�\�Ϙ̶/i'�wl����ά� ��8��J�<���N���;ÆRX���pP��\�w�B��W���/��Iҋ��i�h�H���+�:1D��']��f6;4��a�P�tG5Z�9�%͚_h*�L&##���>w���=�Z���L9U��$b����%�U^�$��&�ք���=���6;N�;��}g~����(>||�;�X��I�#�'�'�H������7����?���#��>����o$�������xa�����^� �� �O��}���G4����	��������}��%Y�(�Z����]��X�i��6�T8Z��t���Xw�"�~��GC������X�-��7���^j�+�{?�f��#޻��%�G|��9��|�����K�R���e����e.o�%ķ�%�<P��K��P�f]-E)nun{�8�Qh��ZƯܞN�8s5^��Ao�˝�f�lL�'�q�����`G�+Yr�v�S�e��p;�7�U)O)!��Ö��@�>�hŧT�S�͟��sW�c-�d�߾�5����#��yp}�i�-��=i��*�";����)�~S~L��M�$�S��p�EL�C�@,}�j��2'vK�]Nz�I]Q���9��Hq�h,{y2��=��&����֭%F��ú��yJ�uPX
Ν����Ʈ.�ǒ��V]����� �����A���?!�Ȁ�?f"�Ҿ4cBʿ>��4���$��f��2��g�������c2�"���(�����_���!������d&���h��`���E��(����1n������{J����^�|�V��ȕ�Z�����?����;�?CA�p�����?��!��?d�0��5�����	$�?$x-��)o�?�k����Sw��JO_l]�O�h������_X4�4������%؈������?������7��&�2|��u_�~/i?�my?�Is��(%�h	G^��5m׋���;>������4�i���ɞ����u�ٮY�g��3q6.'�F;I�]{tK��������y??��u��{W��&�e��+4nGGO�3Y�"u�' ���Ą�@�����������r�ee�a[�X�;��{�cQ�fG�T��E�	�ݲ�y8Vg���&�<[��r�ߏ���q՝J*>�F��ǆ��!W�N�����`�E҈��R;kzUG-��-r��{�9��u���z��G��V�~��y�ĭ���M)���Bk����2���2A$#~�]7T�Rp����x��E����x	^�����'"�����%� ��T�#�����$\o��R;t�ȡ"��u�x ���U��&���k5����˲%Q-�����{-~����~G�CR�����b�w��0�i ��_Ija��\��?k����2��m `8(7H���p������T��>�P?��؛�QYmz�]�)�����Y�k���?�Z�|�h~>�xbǗy���u1Q@>q�:J����^
�vuul��x�|^V��,/��e�
�ޡ����4u咝=^K�+u�����Yx!/}N��i�{"vý����.1���=�W{�3��M���ؽ��ON�J"\���󨿙Wp�V�=��:e�_��y���m���^:�b�����y�G�ŲQ�<���^$��9�Z�k���l����\�"3����[���h+�M^�������=�b[ʮ�M�]]���zm���P0�:9�(�yK���!k�fuH���d���-kh�1
�A��Wuǈ!ߣ�r��+�7�i�A�������T�F��)���߷�����O�!M��D��!����O
�S�B�'�B�'�����Y��S8t��߷�����vH���.g�E�����0��
�������������h�ϳe}��/!�����?�A��r��̕�;���t��*�Z�� ��?{������� +�O��>w �?���O�W�0�SJȒ��"{ ��g����_p��4��_������C�����
������~���������T���������}�\�����?RB�*B�C.��+���t ��� ��� ��������= ��o������̐�_��������!��a�?���?���?d;����RA��/�MH���߷����7� �+��!�?+�"����� ��������\�?��񟌐��[�� t}��� ��}�<�	���a������h�uL-3J�*$��ը:���(�)]g�:���fjE��P��U0�Dc4�>�Y��/�<�����!�?����}y�E��0���R�5�ŵ$-��_���ϑP�$,R���^Ϥ��F�O�VU�C~��b�V��� ��R%l���p�uZ��g���a�1:m�8�g�"Q䶣r��M��!��
i���Nb{��+un���֤�5E!�q���Ni�x[�5˼q��ae�U���1޻:��/xΐ���?�CV���Q�< �?��!��?�!K�?��cf}�y����Ï��8�l�N�w�	:�0$bŨ���$j��z��](.w�lp���x�Y�;��F�|��m���7�8��~]*���i�J�m�E]�Djy��b��OeA�$�D�|���}��"�	�3B����<j��xQ�B�E��e����/����/����Q�h���G������������:�_�m�������ؖn�����g?\�}<�*'rs	������w�!/{�XLf��۟�(�:�yx�Y��;Q��:�"S�ä85�Iq���@NE׫Ē���nS�Ķ�V^I�)�j9h�.%4�j�۶X�����ɭ��.���`$�o��s� r=��T��8�7�%���>i�Ṉ@�b��#�/��z���Wj���y���X�-�8{:�����xO���ި
թ��~�l�36j��aV����������A�<"�ΘT�݁���&aJ�vP�~���|/���S���~v���${�i�����a7�?�Ր��r��̍�/�?����^z�A��=���������C���L�?)���9����3��F���������$�Y_�{�?���O������T�'�������#NC�G �G����E.�~���_*�\������������!3��a��L�������%��#|����(�?䰼���r�c[`�SzahW��0��-{���T��V �W��z��H~�3�I����i�]j;���K���^��w����y�^�z]]\��
�%'�Ƣ��۝&��Z��`ݹݰ4��7�����9�ecr�nĺi�^}���"�[�{)�En��*�p����6;2�"?.2L�H�ñ:�5a����6��u��=Տ��TR�5�l�86ԧ��vx~kb�����jiH#�kK��=,�U�8G�ȵ^���D^�IT�[��e�Z�O�A.���g���ߋI�������[���a�?3���>B/@��E�������T �_���_���m�O��OF�\�}�<�Kq������_.���3B�����𳑋���3����j5����X�N�F�
١�H�q�m[��/5�/�?|�?�$��=��k��Zی��2�?�@������be�ɮ�P�Q����Ҍ[���^gВ�Y��,U�4��ý[ƫGu��Vil��&j%:�l�����XsL� I� �L ��Q@?b�>+��ƺhU���2���˅�K�SG[fEK*{���*j��9*�l��`T��:nS�^��K����U�.���#�r~�0�����ߘ���RA����$�Y_����������%���c	�?���
�hJ�1ZєJY�%L%
SiR�)� �\�)\30����t���J�!4�>�Y�﯌<����?!�?���?�̜ؤSV���ǜ�����x[���� �������YX)^��<��@{��y�"����N��3W�5"�(9�<��(��~Q�Oe�(.O�n=��pZLj�<�
��t �زNa���"�?�f�L��d��/��#�?��!��?�!s��0��w�<�?���G��d��XKQ�Ju]`H]��dɵ�A��m�7C=.�������HmG�-�y^�l4w�F�o6&�ǁ0��Xį5b�.�m�+5}���I�H���hw��q�czpH��"��U�Ő������M�	�3D.��+3@��A��A��,�@f�<�?�*���_��D���G�״4��8���El9	G[̹J���������� �L���2����p�(�"o3^�nDA{p\�U[Y�>���X>U�ZҖ�2iz0��֦ԩ+#�D)͆�u�������í�<�:}*�D�q
�z�:�{:W��8�7��Q�'Hlo$rQ���^ �U0��<?j�^�,9�H���W��1�RLY��vU�����}�����C��O�kͦ>�3��a��^D>3�<�Ta���zMo{��3c��XΒ�#��6�Ƕ14�H6;�f!yJ��6-z�O�BcL�-�Q����hF��Ҭ����7��F������1<����
�cd��>���i�?��sSw
��WB���ܸ�{���<*��Q�����2����]vX{��;�"���C���w{���'�s�
R�3��]��Bn�j������<�T��G�RG__v��z|�����;���'�p�,W���K����d���OޒP|Z�X��_��i����HV�����_�j;����� ��:���������������:yc6���@�>�NUu-^�Fv�i����k���s�ML'��${�|E-��^�v����[�~���������?
ڢ���x�⛷�q��~��y�����M������-�O�^�������7�v���o����E8�+<�ۣ�n�xܬ�E����+<,�������_�=�_�S��ש����+��v4%޽k�/}P�������؎YX�����,�A����`����rK茆���V�䗜�F���At�ro����H��u�k�;��&>S����cе���>���&�2�Z|پ��w��n����(,&�ω9�ܨj���⡗���'[wm�K�_�'���Y<���ﻂ��t�N[���F�� ��]���y���)��ͫ.�29���Sn����}|��6
            ������ � 