        // BLE UUIDs from the Arduino code
        const FALL_SERVICE_UUID = '19b10000-0000-537e-4f6c-d104768a1214';
        const FALL_CHARACTERISTIC_UUID = '19b10000-1111-537e-4f6c-d104768a1214';
        const BATTERY_SERVICE_UUID = '0000180f-0000-1000-8000-00805f9b34fb';  
        const BATTERY_CHARACTERISTIC_UUID = '00002a19-0000-1000-8000-00805f9b34fb'; 

        const BOT_TOKEN = '7795056451:AAEeJD6Dg7s1WL2hB8JeSNCMZdtqOZNcMaM';
        const CHAT_ID = '-4600073095'; 
        
        let fallCharacteristic = null;
        let device = null;
        let isConnected = false;
        let alarmSound = document.getElementById('alarmSound');
        //let soundEnabled = document.getElementById('soundEnabled');
        let connectionSound = document.getElementById('connectionSound');
        let disconnectionSound = document.getElementById('disconnectionSound');
        let criticalSound = document.getElementById('criticalSound');

        const connectBtn = document.getElementById('connectBtn');
        const resetAlarmBtn = document.getElementById('resetAlarmBtn');
        const statusDiv = document.getElementById('status');

        connectBtn.addEventListener('click', handleConnectionClick);
        resetAlarmBtn.addEventListener('click', resetAlarm);

/*
       async function sendTelegramAlert(message) {
            const encodedMessage = encodeURIComponent(message);
            const url = `https://api.telegram.org/bot${BOT_TOKEN}/sendMessage?chat_id=${CHAT_ID}&text=${encodedMessage}&parse_mode=HTML`;
            
            try {
                const response = await fetch(url);
                
                if (!response.ok) {
                    console.error('Telegram API error:', await response.text());
                    throw new Error('Failed to send Telegram notification');
                }
                
                console.log('Telegram notification sent successfully');
            } catch (error) {
                console.error('Error sending Telegram notification:', error);
            }
        }
*/

    async function sendTelegramAlert(message) {
        const url = `https://api.telegram.org/bot${BOT_TOKEN}/sendMessage`;
        const payload = {
            chat_id: CHAT_ID,
            text: message,
            parse_mode: 'HTML'
        };

        try {
            const response = await fetch(url, {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json'
                },
                body: JSON.stringify(payload)
            });

            if (!response.ok) {
                console.error('Telegram API error:', await response.text());
                throw new Error('Failed to send Telegram notification');
            }

            console.log('Telegram notification sent successfully');
        } catch (error) {
            console.error('Error sending Telegram notification:', error);
        }
    }

        
        async function handleConnectionClick() {
            if (isConnected) {
                await disconnectDevice();
            } else {
                await connectToDevice();
            }
        }

        async function disconnectDevice() {
            if (device && device.gatt.connected) {
                await device.gatt.disconnect();
            }
            stopAlarm();
        }



        function playAlarm() {
                alarmSound.currentTime = 0;
                alarmSound.play().catch(e => console.log('Audio play failed:', e));
        }

        function stopAlarm() {
            alarmSound.pause();
            alarmSound.currentTime = 0;
            stopCritical();
        }

        function playCritical() {
            criticalSound.currentTime = 0;
            criticalSound.play().catch(e => console.log('Audio play failed:', e));
        }

        function stopCritical() {
            criticalSound.pause();
            criticalSound.currentTime = 0;
        }

        function playConnectionSound() {
        connectionSound.currentTime = 0;
        connectionSound.play()
        .then(() => console.log('Audio played successfully'))
        .catch(e => {
            console.log('Audio play failed:', e);
            // Retry playing with user interaction
            connectionSound.play();
        });
}

        function playDisconnectionSound() {
            disconnectionSound.currentTime = 0;
            disconnectionSound.play().catch(e => console.log('Audio play failed:', e));
        }


        async function connectToDevice() {
            try {
                device = await navigator.bluetooth.requestDevice({
                    filters: [{ name: 'Man Down' }],
                    optionalServices: [FALL_SERVICE_UUID, BATTERY_SERVICE_UUID]
                });

                statusDiv.textContent = 'Connecting...';

                // Fall Service
                const server = await device.gatt.connect();
                const service = await server.getPrimaryService(FALL_SERVICE_UUID);
                fallCharacteristic = await service.getCharacteristic(FALL_CHARACTERISTIC_UUID);
                await fallCharacteristic.startNotifications();
                fallCharacteristic.addEventListener('characteristicvaluechanged', handleAlarmChange);

                // Battery Service
                const batteryService = await server.getPrimaryService(BATTERY_SERVICE_UUID);
                const batteryCharacteristic = await batteryService.getCharacteristic(BATTERY_CHARACTERISTIC_UUID);
                await batteryCharacteristic.startNotifications();
                batteryCharacteristic.addEventListener('characteristicvaluechanged', handleBatteryChange);
                
                // Initial battery level
                const batteryInitial = await batteryCharacteristic.readValue();
                updateBatteryLevel(batteryInitial.getUint8(0));

                playConnectionSound();

                statusDiv.textContent = 'Status: Connected';
                statusDiv.className = 'connected';
                connectBtn.textContent = 'Disconnect';
                isConnected = true;

                device.addEventListener('gattserverdisconnected', handleDisconnection);

                const connectionMessage = 
`🟢 <b>DISPOSITIVO CONNESSO</b>

⏰ ${new Date().toLocaleString('it-IT')}
✅ Sistema attivo e pronto al monitoraggio`;
        
        await sendTelegramAlert(connectionMessage);
                
            } catch (error) {
                console.error('Error:', error);
                
                // Check if the error is due to user cancelling the request
                if (error.name === 'NotFoundError' || error.message.includes('User cancelled')) {
                    statusDiv.textContent = 'Status: Disconnected';
                    return; // Don't trigger disconnection handling
                }
                
                // For actual connection errors
                statusDiv.textContent = `Error: ${error.message}`;
                
                // Only handle disconnection if we were previously connected
                if (isConnected) {
                    handleDisconnection();
                }
            }
        }

        function handleAlarmChange(event) {
            const value = event.target.value.getUint8(0);
            const timestamp = new Date().toLocaleString('it-IT');
            switch(value) {
                case 0x00:
                    statusDiv.textContent = 'Status: Connected - No Alarm';
                    statusDiv.className = 'connected';
                    resetAlarmBtn.style.display = 'none';
                    stopAlarm();
                    const okMessage = `
✅ <b>La persona sta bene</b> ✅

Il sistema sta monitorando lo stato della persona`;
                    sendTelegramAlert(okMessage);
                    break;
                case 0x01:
                    statusDiv.textContent = 'Status: Fall Detected!';
                    statusDiv.className = 'alarm';
                    resetAlarmBtn.style.display = 'block';
                    playAlarm();
                    stopCritical();
                    const fallMessage = `
🚨 <b>ATTENZIONE: Rilevata Caduta!</b>
                    
⏰ <i>Ora</i>: ${new Date().toLocaleString('it-IT')}
📍 <i>Posizione</i>: Non disponibile
ℹ️ <i>Stato</i>: In attesa di conferma recupero
                    
<i>Il sistema sta monitorando il recupero della persona. Se non viene rilevato un recupero entro 20 secondi, verrà attivato l'allarme di emergenza.</i>`;
                    sendTelegramAlert(fallMessage);
                    break;
                    
                case 0x02:
                    statusDiv.textContent = 'Status: ALARM - MAN DOWN!';
                    statusDiv.className = 'alarm';
                    resetAlarmBtn.style.display = 'none';
                    connectBtn.style.display = 'none';
                    stopAlarm();
                    playCritical();
                    const emergencyMessage = `
🚨🚨 <b>EMERGENZA GRAVE: PERSONA A TERRA!</b>
                    
⏰ <i>Ora</i>: ${new Date().toLocaleString('it-IT')}
📍 <i>Posizione</i>: Non disponibile
❗️ <i>Stato</i>: Richiesto intervento immediato
                    
La persona non si è rialzata dopo la caduta. È necessario un intervento immediato!`;
                    sendTelegramAlert(emergencyMessage);
                    break;
            }
        }

       async function resetAlarm() {
            if (!fallCharacteristic || !isConnected) {
                console.error('Device not connected');
                statusDiv.textContent = 'Error: Device not connected';
                handleDisconnection();
                return;
            }
        
            try {
                // Send reset command
                await fallCharacteristic.writeValue(new Uint8Array([0x00]));
                
                //Update UI
                statusDiv.textContent = 'Status: Connected - No Alarm';
                statusDiv.className = 'connected';
                resetAlarmBtn.style.display = 'none';
                stopAlarm();
            } catch (error) {
                console.error('Error resetting alarm:', error);
                statusDiv.textContent = `Error: ${error.message}`;
                handleDisconnection();
            }
        }

        function handleDisconnection() {
            stopAlarm();
            playDisconnectionSound();
            const disconnectionMessage =`
🔴 <b>DISPOSITIVO DISCONNESSO</b>

⚠️ Il monitoraggio è stato interrotto`;
            sendTelegramAlert(disconnectionMessage);
            statusDiv.textContent = 'Status: Disconnected';
            statusDiv.className = 'disconnected';
            connectBtn.textContent = 'Connect Device';
            resetAlarmBtn.style.display = 'none';
            isConnected = false;
            fallCharacteristic = null;
            device = null;
        }

        // Check battery level change
        function handleBatteryChange(event) {
            const batteryLevel = event.target.value.getUint8(0);
            updateBatteryLevel(batteryLevel);
        }
        
        // Update battery level
        function updateBatteryLevel(level) {
            document.getElementById('batteryLevel').textContent = `Batteria: ${level}%`;
        }

        // Check Web Bluetooth API support
        if (!navigator.bluetooth) {
            statusDiv.textContent = 'Web Bluetooth API is not supported in this browser';
            connectBtn.disabled = true;
        }

