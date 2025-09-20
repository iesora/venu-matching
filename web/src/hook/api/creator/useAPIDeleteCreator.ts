import { AxiosError } from "axios";
import { useMutation, UseMutationOptions } from "react-query";
import { axiosInstance } from "@/utils/url";
import { jsonHeader } from "@/utils/url/header";
import { creatorURL } from "@/utils/url/creator";
import { Creator } from "@/type";

const deleteCreator = async (id: number) => {
  const headers = await jsonHeader;
  const response = await axiosInstance.delete(`${creatorURL}/${id}`, {
    headers,
  });
  return response.data;
};

export const useAPIDeleteCreator = (
  mutationOptions?: UseMutationOptions<Creator, AxiosError, number>
) => {
  return useMutation<Creator, AxiosError, number>(
    deleteCreator,
    mutationOptions
  );
};
