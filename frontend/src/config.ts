type RuntimeConfig = {
	VITE_API_BASE_URL: string;
};

export const config: RuntimeConfig = {
	...((window as any).RUNTIME_CONFIG || {}),
};
